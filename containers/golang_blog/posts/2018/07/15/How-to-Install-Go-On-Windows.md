A fairly easy write up on installing Go on Windows 10. Also a script to run to do it all for you.

## Get and Install Go

1. Download Go

    Go provides a Windows MSI (Microsoft Installer) for Windows XP Service Pack 3 and later Windows systems. Can download the file from: [https://golang.org/dl/](https://golang.org/dl/)

2. Run the Go msi file

    Once the file (ie. go1.10.3.windows-amd64.msi) is downloaded, you can run the file. Follow the prompts to install to the default location (C:\Go\\).

    > note: the msi installer may as for you to accept running the file with admin rights.

## Add Go Executable to PATH

Adding the Go executable to your Windows user PATH allows you to call `go` commands from anywhere in a CLI (command line interface).

### Through the GUI

1. Open File Explorer
1. Right click "This Computer" (what used to be "My Computer") and select Properties
1. Click Advanced system settings

    > the advanced tab should be selected.

1. Click Environment Variables

> note: can use Windows Search
1. click the Windows icon key on the keyboard
1. type `environment var` and press enter

## Set GOROOT

## Set GOPATH

## Check Go Out

## Automate the Install for Next Time

```bat
script here
```
