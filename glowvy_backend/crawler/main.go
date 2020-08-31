package crawler

import (
	"database/sql"
	"fmt"

	"dimodo_backend/utils/translate"

	"github.com/bugsnag/bugsnag-go"
	"github.com/gchaincl/dotsql"
)

type Crawler struct {
	DB          *sql.DB
	BrandiDot   *dotsql.DotSql
	GlowpickDot *dotsql.DotSql
	tr          *translate.Translator
}

//NewAPI loads configuration files and initializes the router, DB, models, and controller objects.
func NewCrawler() *Crawler {
	//boolPtr is a pointer to a boolean, so we need to use
	//*boolPtr to get the boolean value and pass it into our
	//LoadingConfig function
	cfg := LoadConfig(false)
	dbCfg := cfg.Database

	db, err := sql.Open(dbCfg.Dialect(), dbCfg.ConnectionInfo())
	if err != nil {
		bugsnag.Notify(err)
		panic(err)
	}

	BrandiDot, _ := dotsql.LoadFromFile("sql/brandi.pgsql")
	GlowpickDot, _ := dotsql.LoadFromFile("sql/glowpick_crawl.pgsql")
	tr, _ := translate.NewTranslator()

	c := Crawler{
		DB:          db,
		BrandiDot:   BrandiDot,
		GlowpickDot: GlowpickDot,
		tr:          tr,
	}

	fmt.Println("Project -", cfg.Name)
	fmt.Println("Database Successfully connected!")
	fmt.Println("Run Port :", cfg.Port)
	return &c
}