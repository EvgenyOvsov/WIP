package main

import (
	"context"
	"github.com/go-redis/redis"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

type Info struct {
	Value int
}
type Request struct {
	Delta int
}
var rdb *redis.Client
var ctx context.Context
func main(){
	rdb = redis.NewClient(&redis.Options{
		Addr: "redis:6379",
		Password: "",
		DB: 0,
	})
	initial := rdb.Get("MAIN")
	if initial==nil{
		rdb.Set("MAIN", "0", -1)
	}
	e := echo.New()
	e.Use(middleware.CORS())
	e.GET("/", func(context echo.Context) error {
		var i Info
		var err error
		i.Value, err = rdb.Get("MAIN").Int()
		if err==nil {
			return context.JSON(200, i)
		}else{
			return context.JSON(500, map[string]string{"status": err.Error()})
		}
	})
	e.POST("/up", func(context echo.Context) error {
		var r Request
		if err := context.Bind(&r); err != nil {
			return err
		}
		if r.Delta>0{
			rdb.Incr("MAIN")
		}
		return context.JSON(200, map[string]string{"status":"ok"})
	})
	e.HideBanner = true
	e.Start(":5000")

}
