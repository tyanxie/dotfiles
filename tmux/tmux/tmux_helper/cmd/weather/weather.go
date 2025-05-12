// Package weather 通过wttr.in获取当前天气信息命令
package weather

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"time"

	"github.com/urfave/cli/v2"
)

const (
	filename           = "tmux-weather-go.tmp" // 存储数据的文件名称
	validPeriod        = 10 * time.Minute      // 数据有效时间
	errorValidPeriod   = 15 * time.Second      // 错误有效时间
	timeout            = 5 * time.Second       // 超时时间
	tempUnit           = "°C"                  // 温度单位
	defaultDescription = "未知"                  // 默认天气状态描述
)

// descriptionTranslateMap 天气描述翻译map，部分天气描述wttr.in没有汉化，需要手动转换
var descriptionTranslateMap = map[string]string{
	"Haze":                         "雾霾",
	"小雨, rain":                     "小雨",
	"Patchy rain nearby":           "局部降雨",
	"Light rain with thunderstorm": "小雨伴雷阵雨",
	"Rain shower":                  "阵雨",
}

// 目标地址信息，可以是城市或地址名称，具体参考wttr.in官方文档：https://github.com/chubin/wttr.in
var location string

// command 命令实例
var command = &cli.Command{
	Name:    "weather",
	Aliases: []string{"w"},
	Usage:   "Get current weather information by wttr.in",
	Action:  action,
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:    "location",
			Aliases: []string{"l"},
			Usage: "Target address information, which can be a city or address name. " +
				"For details, please refer to the official document of wttr.in: " +
				"https://github.com/chubin/wttr.in",
			Value:       "Shenzhen",
			Destination: &location,
			DefaultText: "Shenzhen",
		},
	},
}

// Command 创建新的获取系统状态命令实现
func Command() *cli.Command {
	return command
}

// action 执行函数
func action(cCtx *cli.Context) error {
	// 当前时间
	now := time.Now()
	// 构造临时文件路径
	name := filepath.Join(os.TempDir(), filename)
	// 判断是否需要拉取数据
	var needFetchData bool
	// 读取文件内容
	file, err := os.ReadFile(name)
	// 如果发生错误并且错误不是文件不存在，则需要返回错误
	if err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("read file failed, filename:%s, err:%w", name, err)
	}
	// 如果文件内容不为空则进行解析并判断是否需要拉取数据
	data := &Data{}
	if len(file) > 0 {
		// 解析文件内容，失败则直接返回错误
		err = json.Unmarshal(file, data)
		if err != nil {
			return fmt.Errorf("unmarshal file data failed, filename:%s, err:%w", name, err)
		}
		// 超过数据有效时间或超过错误有效时间则需要拉取数据
		// 优先判断错误有效时间，其次再判断是否超过数据有效期
		if data.FetchErrorTime > 0 {
			needFetchData = now.Sub(time.Unix(data.FetchErrorTime, 0)) > errorValidPeriod
			// 存在错误但不用拉取数据，则直接返回错误
			if !needFetchData {
				return errors.New(data.FetchErrorMessage)
			}
		} else {
			needFetchData = now.Sub(time.Unix(data.UpdateTime, 0)) > validPeriod
		}
	} else {
		// 文件内容为空，需要拉取数据
		needFetchData = true
	}
	// 如果需要拉取数据，则进行拉取
	if needFetchData {
		// 拉取数据
		rsp, err := fetchData(cCtx.Context)
		if err != nil {
			// 发生错误时记录错误时间和错误信息
			data.FetchErrorTime = now.Unix()
			data.FetchErrorMessage = err.Error()
			// 写入文件
			saveFileErr := saveFile(name, data)
			if saveFileErr != nil {
				return saveFileErr
			}
			return err
		}
		// 未发生错误更新数据和拉取时间
		data.SourceRsp = rsp
		// 更新拉取时间
		data.UpdateTime = time.Now().Unix()
		// 重写错误时间和信息
		data.FetchErrorTime = 0
		data.FetchErrorMessage = ""
	}
	// 构造输出数据
	message, err := generateMessage(data)
	if err != nil {
		return err
	}
	// 保存数据
	err = saveFile(name, data)
	if err != nil {
		return err
	}
	// 输出数据
	fmt.Println(message)
	return nil
}

// fetchData 拉取数据
func fetchData(ctx context.Context) (*WttrRsp, error) {
	// 构造url，使用PathEscape编码location，防止意外参数
	rawURL := "https://wttr.in/" + url.PathEscape(location)

	// 超时时间
	requestCtx, requestCancel := context.WithTimeout(ctx, timeout)
	defer requestCancel()

	// 创建请求
	req, err := http.NewRequestWithContext(requestCtx, http.MethodGet, rawURL, nil)
	if err != nil {
		return nil, fmt.Errorf("create request failed, rawURL:%s, err:%w", rawURL, err)
	}

	// 添加请求参数
	query := req.URL.Query()
	// 语言
	query.Add("lang", "zh-cn")
	// 目标数据格式
	query.Add("format", "j1")
	// 写回请求参数
	req.URL.RawQuery = query.Encode()

	// 发送请求
	rsp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("send request failed, url:%s, err:%w", req.URL.String(), err)
	}
	// 退出前关闭body
	defer rsp.Body.Close()
	// 判断http状态码
	if rsp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("response status code invalid, status: %s, code:%d", rsp.Status, rsp.StatusCode)
	}

	// 读取响应
	body, err := io.ReadAll(rsp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response body failed: %w", err)
	}

	// 解析响应数据
	wttrRsp := &WttrRsp{}
	err = json.Unmarshal(body, wttrRsp)
	if err != nil {
		return nil, fmt.Errorf("parse response body failed: %w", err)
	}

	return wttrRsp, nil
}

// generateMessage 构造输出消息
func generateMessage(data *Data) (string, error) {
	// 获取当前时间
	now := time.Now()
	// 如果当前为21点后，则返回明日天气状态，否则返回今日天气状态
	hour := now.Hour()
	if hour >= 21 {
		return generateTomorrowMessage(data)
	}
	return generateCurrentMessage(data)
}

// generateCurrentMessage 生成当前天气状态
func generateCurrentMessage(data *Data) (string, error) {
	// 当前数据
	if len(data.SourceRsp.CurrentCondition) != 1 {
		return "", fmt.Errorf("invalid current condition length: %d", len(data.SourceRsp.CurrentCondition))
	}
	current := data.SourceRsp.CurrentCondition[0]
	// 当前气温
	if current.TempC == "" {
		return "", fmt.Errorf("current TempC is empty")
	}
	// 构造输出消息
	message := current.TempC + tempUnit
	description := current.LangCN.GetFirst()
	if description != "" {
		// 解析描述信息
		description = parseDescription(description)
		// 拼接描述
		message = description + " " + message
	}

	// 返回结果
	return message, nil
}

// generateTomorrowMessage 生成明天天气状态
func generateTomorrowMessage(data *Data) (string, error) {
	// 获取明日时间
	date := time.Now().AddDate(0, 0, 1).Format(time.DateOnly)
	// 获取明日天气
	var daily *WttrRspDaily
	for _, w := range data.SourceRsp.Weather {
		if w.Date == date {
			daily = w
			break
		}
	}
	if daily == nil {
		return "", fmt.Errorf("tomorrow weather info not found: %s", date)
	}
	// 天气状态描述仅获取9点和21点的描述
	morning := defaultDescription
	evening := defaultDescription
	for _, hourly := range daily.Hourly {
		// 获取描述
		description := hourly.LangCN.GetFirst()
		if description == "" {
			continue
		}
		// 解析描述
		description = parseDescription(description)
		// 按照时间获取信息
		switch hourly.Time {
		case "900":
			morning = description
		case "2100":
			evening = description
		}
	}
	// 如果早晚描述信息一致，则仅使用其中一个
	description := morning
	if evening != morning {
		description = description + "～" + evening
	}
	// 拼接结果
	return fmt.Sprintf(
		"明日：%s %s/%s%s",
		description,
		daily.MintempC,
		daily.MaxtempC,
		tempUnit,
	), nil
}

// parseDescription 解析描述信息，部分未汉化描述返回映射描述信息
func parseDescription(description string) string {
	if t, ok := descriptionTranslateMap[description]; ok && t != "" {
		return t
	}
	return description
}

// saveFile 保存数据到文件
func saveFile(name string, data *Data) error {
	// 序列化数据
	file, err := json.Marshal(data)
	if err != nil {
		return fmt.Errorf("marshal data failed: %w", err)
	}
	// 写入文件内容
	err = os.WriteFile(name, file, 0644)
	if err != nil {
		return fmt.Errorf("write file failed, filename:%s, err:%w", name, err)
	}
	return nil
}
