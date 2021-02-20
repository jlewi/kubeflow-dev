package main

import (
	"fmt"
)

type SomeModel struct {
}

func (m *SomeModel) Accuracy() float32 {
	return 5.0
}

type OtherModel struct {
}

func (m *OtherModel) Accuracy() float32 {
	return 10.0
}

type Accuracy interface {
	Accuracy() float32
}

func PrintAccuracy(m Accuracy) {
	fmt.Printf("Accuracy %v\n", m.Accuracy())
}

func main() {
	s := &SomeModel{}
	PrintAccuracy(s)

	o := &OtherModel{}
	PrintAccuracy(o)
}

