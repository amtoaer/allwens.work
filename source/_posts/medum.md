---
title: medum-一款命令行待办事项管理器
date: 2020-05-23 23:09:29
tags: [go]
categories: 开发记录
photos: /img/banner/images/10.png
---

前几天整了一个命令行待办事项管理器：[medum](https://github.com/amtoaer/medum)。注意到自己已经有一阵子没发过文章了，正好今晚有空，把它拿出来随便聊聊，顺便水一篇233（（

## 名称由来

这个项目叫做`medum`，为什么呢？

因为它的开发目的是防止我忘记`ddl`，所以从一开始，它就是作为一个备忘录（memorandum）而被设计的。我从*memorandum*这个单词中取了前两个和后三个字母进行拼接，于是`medum`诞生了。（好随意啊XD

<!--more-->

## 代码结构

具体的开发初衷已经写在了`README.md`里，所以接下来就说说代码结构吧。

下面是所有的代码文件：

```bash
.
├── config
│   └── config.go
├── main.go
├── output
│   └── output.go
├── path
│   └── path.go
├── public
│   └── public.go
├── sqlite
│   └── sqlite.go
└── text
    └── text.go
```

每个模块的功能如下：

+   `path.go`：负责获取配置文件夹路径，配置文件路径和sqlite数据库路径。
+   `config.go`：负责读取配置文件，并在配置文件不存在的情况下写入默认配置。
+   `public.go`：存放公共的结构体，包括在多个文件进行引用的`Configuration`（配置文件）、`Event`（事项）。
+   `sqlite.go`：sqlite数据库的打开，插入，更新，查询，删除功能的实现。
+   `text.go`：存放该程序近乎所有的文本信息（包括报错、提醒以及sql语句）。
+   `output.go`：将配置文件的颜色映射为函数，对彩色输出函数的反射调用进行一层封装。

## 设计思路

1.  首先从功能出发，既然要读取文件，那么获取路径是必须的，于是首先考虑实现`path.go`：

    ```go
    // path.go
    func GetPath() string { //获取文件夹路径，路径为~/.medum
    	path, err := homedir.Dir()
    	if err != nil {
    		fmt.Printf(text.HomedirError, err)
    		os.Exit(1)
    	}
    	return filepath.Join(path, ".medum")
    }
    // 后面获取配置文件和数据的路径很简单，在文件夹路径后加文件名就可以
    ```

    

2.  有了路径，接下来就是要到路径中读取文件啦，但文件读入到哪儿呢？为了让内容有处可去，应该先实现一个配置文件的结构体。考虑到配置文件自定义的是颜色，必定需要被输出模块读取，所以将其分离放在`public.go`里，接着再写`config.go`：

    ```go
    // public.go
    type Configuration struct {
    	NumberColor string
    	EventColor  string
    	TimeColor   string
    }
    ```

    ```go
    // config.go
    func ReadConfig() *public.Configuration {
    	configPath := path.GetConfigPath()
    	// 检测配置文件是否存在，不存在则写入默认配置
    	if _, err := os.Stat(configPath); err != nil && !os.IsExist(err) {
    		writeInitConfig(configPath)
    	}
        // ...
    	decoder := json.NewDecoder(file)
    	conf := new(public.Configuration)
        // 将文件读取到conf中
    	err = decoder.Decode(conf)
        // ...
    	return conf
        
    func writeInitConfig(configPath string) {
        // 首先看文件夹是否存在，如果不存在则新建
    	tmp := path.GetPath()
    	if _, err := os.Stat(tmp); !os.IsExist(err) {
    		os.Mkdir(tmp, os.FileMode(0777))
    	}
        // 接着新建配置文件
    	file, err := os.Create(configPath)
    	// 创建默认配置
    	conf := public.Configuration{
    		NumberColor: "red",
    		EventColor:  "blue",
    		TimeColor:   "yellow",
    	}
        // 写入
    	encoder := json.NewEncoder(file)
    	encoder.Encode(conf)
    }
    ```

3.  实现了配置文件的读取，紧接着就是数据的操作了，考虑实现`sqlite.go`，但为了方便修改，尽量将所有的文本内容与逻辑分离，需要先写`text.go`，但在这之前，还要先考虑好事件结构体的内容，所以最终顺序是`public.go`->`text.go`->`sqlite.go`：

    ```go
    // public.go
    // 包括id，事件内容，开始结束日期，当前状态
    type Event struct {
    	ID           int
    	EventContent string
    	BeginDate    int64
    	EndDate      int64
    	IsEnd        uint8
    }
    ```

    ```go
    // text.go
    const (
        // 创建表，其中id自增，event为事件名，开始日期结束日期用时间戳存储。
        // 状态标记方面，一个事件应该有未开始，正在进行，结束三个状态，故isEnd可取0,1,2，对应三种状态
    	CreateTable = `create table if not exists eventList(
    		id integer primary key autoincrement,
    		event varchar(100) not null,
    		beginDate unsigned bigint not null,
    		endDate unsigned bigint not null,
    		isEnd smallint default 1 not null
    	);`
        // 插入一行
    	InsertRow      = `insert into eventList (event,beginDate,endDate) values (?,?,?);`
        // 当前时间大于结束时间则标记超时
    	MarkOutdate    = `update eventList set isEnd=2 where ?>endDate;`
        // 当前时间小于开始时间则标记未开始
    	MarkNotStart   = `update eventList set isEnd=0 where ?<beginDate;`
        // 介于开始结束之间标记正在进行
    	MarkInProgress = `update eventList set isEnd=1 where ? between beginDate and endDate;`
        // 得到所有的事件，按事件状态，结束日期排序
    	QueryRow       = `select * from eventList order by isEnd desc,endDate`
        // 删除超时事件
    	DeleteOutDate  = `delete from eventList where isEnd=2`
        // 对于完成了的事件，通过id删除
    	DeleteID       = `delete from eventList where id=?`
    )
    ```

    ```go
    // sqlite.go
    // 打开数据库
    func openSqliteDB() *sql.DB {
    	db, err := sql.Open("sqlite3", path.GetDataPath())
    	if err != nil {
    		fmt.Printf(text.OpenDBError, err)
    		os.Exit(1)
    	}
    	db.Exec(text.CreateTable)
    	return db
    }
    // 剩余函数逻辑类似，取其中之一举例：
    func InsertSqliteDB(eventContent string, beginDate, endDate time.Time) error {
        // 打开数据库
    	db := openSqliteDB()
        // 结束时关闭
    	defer db.Close()
        // 执行语句
    	_, err := db.Exec(text.InsertRow, eventContent, beginDate.Unix(), endDate.Unix())
    	return err
    }
    ```

4.  接下来考虑实现`output.go`：

    ```go
    // output.go
    // 支持的所有颜色（采用map[string]interface{}存储）
    var funcs = map[string]interface{}{
    	"red":       color.New(color.FgRed),
    	"blue":      color.New(color.FgBlue),
    	"cyan":      color.New(color.FgCyan),
    	"green":     color.New(color.FgGreen),
    	"yellow":    color.New(color.FgYellow),
    	"magenta":   color.New(color.FgMagenta),
    	"white":     color.New(color.FgWhite),
    	"black":     color.New(color.FgBlack),
    	"hired":     color.New(color.FgHiRed),
    	"hiblue":    color.New(color.FgHiBlue),
    	"hicyan":    color.New(color.FgHiCyan),
    	"higreen":   color.New(color.FgHiGreen),
    	"hiyellow":  color.New(color.FgHiYellow),
    	"himagenta": color.New(color.FgHiMagenta),
    	"hiwhite":   color.New(color.FgHiWhite),
    	"hiblack":   color.New(color.FgHiBlack),
    }
    // 使用reflect包进行动态调用
    func call(m map[string]interface{}, color string, params ...interface{}) {
    	function := reflect.ValueOf(m[color]).MethodByName("Printf")
    	in := make([]reflect.Value, len(params))
    	for index, param := range params {
    		in[index] = reflect.ValueOf(param)
    	}
    	function.Call(in)
    }
    
    // 将call进行一层封装，对外公开Call函数
    func Call(color string, params ...interface{}) {
    	call(funcs, color, params...)
    }
    
    ```

5.  万事俱备，最后只需要在主函数中完成调用逻辑即可（当然还需要补全一些错误输出、给用户的提示等等，不过那些已经很简单了）：

    ```go
    // main.go
    // 接受的命令行参数
    var (
    	begin  string
    	end    string
    	name   string
    	remove bool
    	done   int
    )
    
    func main() {
    	app := &cli.App{
    		// 省略掉参数绑定等流程
    		Action: func(c *cli.Context) error {
                // 读取配置文件
    			conf := *config.ReadConfig()
    			if remove {
                    // -r：首先标记过期事件，接着删除之
    				sqlite.UpdateSqliteDB(text.MarkOutdate)
    				err := sqlite.DeleteOutDate()
    				if err != nil {
    					fmt.Printf(text.DeleteOutdateError, err)
    					os.Exit(1)
    				}
    				fmt.Println(text.DeleteOutdateSuccess)
    			} else if done != 0 {
                    // -d int： 直接删除该id
    				err := sqlite.DeleteID(done)
    				if err != nil {
    					fmt.Printf(text.DeleteIDError, err)
    					os.Exit(1)
    				}
    				fmt.Println(text.DeleteIDSuccess)
    			} else {
    				if len(end) == 0 { 
                      // 如果没有-d，打印事件列表
                      // 这里只标记进行中和超时，是因为在插入事件时已经标记了是否未开始，时间顺序流动，不可能从开始变为未开始
    					sqlite.UpdateSqliteDB(text.MarkInProgress)
    					sqlite.UpdateSqliteDB(text.MarkOutdate)
    					// ...省略输出部分
    					}
    				} else { 
                    // 如果存在-e，则解析结束时间，开始事件如果有就解析，没有默认为当前时间
    					var beginTime, endTime time.Time
    					endTime = handleString(end)
    					if len(begin) == 0 {
    						beginTime = time.Now()
    					} else {
    						beginTime = handleString(begin)
    					}
    					if beginTime.Unix() >= endTime.Unix() {
    						fmt.Println(text.TimeError)
    						os.Exit(1)
    					}
                    // 将输入事件插入
    					err := sqlite.InsertSqliteDB(name, beginTime, endTime)
    					if err != nil {
    						fmt.Printf(text.InsertDBError, err)
    					}
                    // 标记未开始
    					sqlite.UpdateSqliteDB(text.MarkNotStart)
    					fmt.Println(text.InsertSuccess)
    				}
    			}
    			return nil
    		}}
    	err := app.Run(os.Args)
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func handleString(tm string) time.Time {
        // 时间字符串转time.Time，只接受month.day.hour.minute格式
    	tmp := strings.Split(tm, ".")
        // 长度不为4则退出
    	if len(tmp) != 4 {
    		fmt.Println(text.LengthError)
    		os.Exit(1)
    	} else {
            // 补全0，例如将5.20.12.0补全为05.20.12.00，防止解析错误
    		for index := range tmp { 
    			if len(tmp[index]) == 1 {
    				tmp[index] = "0" + tmp[index]
    			}
    		}
    		stdString := fmt.Sprintf(text.MyTime, strconv.Itoa(time.Now().Year()), tmp[0], tmp[1], tmp[2], tmp[3])
    		result, err := time.ParseInLocation(text.StandardTime, stdString, time.Now().Local().Location())
    		if err != nil {
    			fmt.Printf(text.ParamError, err)
    			os.Exit(1)
    		}
    		return result
    	}
    	//useless line, just to prevent warning
    	return time.Now()
    }
    
    func formatTime(begin, end int64, IsEnd uint8) string {
        // 将时间转换成%s time remaining/%s time beginning格式，其中的%s调用下面的formatTimeString函数获取
    	now := time.Now()
    	if IsEnd == 0 {
    		beginTime := time.Unix(begin, 0)
    		dur := beginTime.Sub(now)
    		return fmt.Sprintf(text.TimeBeginning, formatTimeString(dur.Minutes()))
    	} else if IsEnd == 1 {
    		endTime := time.Unix(end, 0)
    		dur := endTime.Sub(now)
    		return fmt.Sprintf(text.TimeRemaining, formatTimeString(dur.Minutes()))
    	} else {
    		return fmt.Sprintf(text.TimeRemaining, "no time")
    	}
    }
    
    func formatTimeString(min float64) string {
        // 获取天/小时/分钟
    	var tmp string
    	if min > 1440 {
    		tmp = strconv.Itoa(int(min/1440)) + " days"
    	} else if min > 60 {
    		tmp = strconv.Itoa(int((min / 60))) + " hours"
    	} else {
    		tmp = strconv.Itoa(int(min)) + " minutes"
    	}
    	return tmp
    }
    ```

这样下来，预想的功能就实现的差不多了，任务成功完成。

## 结束语

okk，这样就结束啦，算是写了个小总结吧。

代码基本全程都有注释（不过为了符合`golang`的规范，使用的是塑料英语XD），觉得自己代码写的还是蛮易读的，欢迎大家阅读给出建议哦！