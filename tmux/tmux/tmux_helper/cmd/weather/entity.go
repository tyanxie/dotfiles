package weather

// Data 存储在文件中的原始数据
type Data struct {
	UpdateTime        int64    `json:"updateTime"`       // 更新时间，单位s
	FetchErrorTime    int64    `json:"fetchErrorTime"`   // 执行失败的时间
	FetchErrorMessage string   `json:"feedErrorMessage"` // 拉取错误信息
	SourceRsp         *WttrRsp `json:"sourceRsp"`        // 原始wttr.in响应
}

// WttrRsp wttr.in响应
type WttrRsp struct {
	CurrentCondition []*WttrRspCurrentCondition `json:"current_condition,omitempty"` // 当前天气信息
	Weather          []*WttrRspDaily            `json:"weather,omitempty"`           // 一日天气数据列表
	NearestArea      []*WttrRspArea             `json:"nearest_area,omitempty"`      // 附近地区
}

// WttrRspCurrentCondition wttr.in响应当前天气信息
type WttrRspCurrentCondition struct {
	LocalObsDateTime string        `json:"localObsDateTime,omitempty"` // 本地观测时间
	LangCN           WttrRspValues `json:"lang_zh-cn,omitempty"`       // 天气状态中文描述
	TempC            string        `json:"temp_C,omitempty"`           // 摄氏度
	FeelsLikeC       string        `json:"FeelsLikeC,omitempty"`       // 体感摄氏度
	Humidity         string        `json:"humidity,omitempty"`         // 湿度
	UvIndex          string        `json:"uvIndex,omitempty"`          // 紫外线指数
}

// WttrRspDaily wttr.in一日天气数据
type WttrRspDaily struct {
	Date     string           `json:"date,omitempty"`     // 日期，格式：2006-01-02
	MaxtempC string           `json:"maxtempC,omitempty"` // 最高温度摄氏度
	MintempC string           `json:"mintempC,omitempty"` // 最低温度摄氏度
	AvgtempC string           `json:"avgtempC,omitempty"` // 平均温度摄氏度
	SunHour  string           `json:"sunHour,omitempty"`  // 光照时间
	UvIndex  string           `json:"uvIndex,omitempty"`  // 紫外线强度
	Hourly   []*WttrRspHourly `json:"hourly,omitempty"`   // 小时级数据列表
}

// WttrRspHourly wttr.in响应小时级数据
type WttrRspHourly struct {
	Time       string        `json:"time,omitempty"`       // 时间，格式：1504
	LangCN     WttrRspValues `json:"lang_zh-cn,omitempty"` // 天气状态中文描述
	TempC      string        `json:"tempC,omitempty"`      // 摄氏度
	FeelsLikeC string        `json:"FeelsLikeC,omitempty"` // 体感摄氏度
	Humidity   string        `json:"humidity,omitempty"`   // 湿度
	UvIndex    string        `json:"uvIndex,omitempty"`    // 紫外线强度
}

// WttrRspArea wttr.in响应地区信息
type WttrRspArea struct {
	AreaName  WttrRspValues `json:"areaName,omitempty"`  // 地区名称
	Country   WttrRspValues `json:"country,omitempty"`   // 国家
	Region    WttrRspValues `json:"region,omitempty"`    // 地区其他信息
	Latitude  string        `json:"latitude,omitempty"`  // 纬度
	Longitude string        `json:"longitude,omitempty"` // 经度
}

// WttrRspValues wttr.in响应Value值列表
type WttrRspValues []*WttrRspValue

// GetFirst 获取第一个数据，长度为0等失败情况返回空字符串
func (w WttrRspValues) GetFirst() string {
	if len(w) == 0 || w[0] == nil {
		return ""
	}
	return w[0].Value
}

// WttrRspValue wttr.in响应Value值
type WttrRspValue struct {
	Value string `json:"value,omitempty"`
}
