package views

import (
	"dimodo_backend/models"
	"log"
	// "lenslocked.com/models"
)

type Data struct {
	Alert *Alert
	User  *models.User
	Yield interface{}
}

type Alert struct {
	Level   string
	Message string
}

const (
	AlertLvlError   = "danger"
	AlertLvlWarning = "warning"
	AlertLvlInfo    = "info"
	AlertLvlSuccess = "success"

	//AlertMsgGeneric is displayed when any random error is encountered by our backend
	AlertMsgGeneric = "Something went wrong. Please try  again, and contact us if the problem persists"
)

func (d *Data) SetAlert(err error) {
	var msg string
	if pErr, ok := err.(PublicError); ok {
		msg = pErr.Public()
	} else {
		log.Println(err)
		msg = AlertMsgGeneric
	}
	d.Alert = &Alert{
		Level:   AlertLvlError,
		Message: msg,
	}
}

func (d *Data) AlertError(msg string) {
	d.Alert = &Alert{
		Level:   AlertLvlError,
		Message: msg,
	}
}

//PublicError interface embeds error interface which allows the
type PublicError interface {
	error
	Public() string
}