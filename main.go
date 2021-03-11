package main

import (
	"context"
	"fmt"
	"log"
	"os/exec"

	"github.com/aws/aws-lambda-go/lambda"
)

func handler(_ context.Context) error {
	cmd := exec.Command("ffmpeg", "-i", "./face3.mp4", "-vf", "fps=1", "/tmp/out%d.png")
	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println(err)
	}
	log.Printf("Execution output:\n%s\n", string(out))

	return err
}

func main() {
	lambda.Start(handler)
}
