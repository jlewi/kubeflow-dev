package main

import (
	"context"
	"encoding/json"
	"fmt"
	crm "google.golang.org/api/cloudresourcemanager/v1"
	"log"
)

// Pformat returns a pretty format output of any value.
func Pformat(value interface{}) (string, error) {
	if s, ok := value.(string); ok {
		return s, nil
	}
	valueJson, err := json.MarshalIndent(value, "", "  ")
	if err != nil {
		return "", err
	}
	return string(valueJson), nil
}

func main() {

	ctx := context.Background()
	//client, err := google.DefaultClient(ctx, crm.CloudPlatformScope)
	//
	//s, err := crm.NewService(ctx, client)
	//
	//crm.NewFoldersService(client)
	//
	//crm.Ne
	s, err := crm.NewService(ctx)

	if err != nil {
		log.Fatalf("Failed with error; %+v", err)
	}

	p := crm.NewProjectsService(s)

	req := &crm.TestIamPermissionsRequest{
		Permissions: []string{"resourcemanager.projects.setIamPolicy",},
	}

	res, err  := p.TestIamPermissions("jlewi-dev", req).Do()

	if err != nil {
		log.Fatalf("Error: %+v", err)
	}

	pRes, _ := Pformat(res)
	fmt.Printf("Result: %+v", pRes)
}


