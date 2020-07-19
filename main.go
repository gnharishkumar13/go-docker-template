package main

import (
	"errors"
	"fmt"
	"os"
	"strings"
)

func main() {
	if err := echo(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "%+v\n", err)
		os.Exit(1)
	}
}

func echo(args []string) error {
	if len(args) < 2 {
		return errors.New("no message to echo")
	}
	_, err := fmt.Println(strings.Join(args[1:], " "))
	return err

}
