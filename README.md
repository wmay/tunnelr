# tunnelr
Control SSH tunneling in R

## Requirements
Mac and Linux systems require `ssh-askpass` to enter passwords interactively. Follow [these instructions](http://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/) to securely login without entering a password (thus not requiring `ssh-askpass`). `tunnelr` relies on PuTTY in Windows, and looks for it in the standard installation paths, e.g., `C:\Program Files\PuTTY` or `C:\Program Files (x86)\PuTTY`.

## Installation

In the R terminal:

```
install.packages("devtools")
library(devtools)
install_github("wmay/tunnelr")
```

## Usage

Run `tunnel()` to open an SSH tunnel, and `closeTunnel()` to close it.

Example:
```
sshTunnel = tunnel(remote_server, server_username, remote_port, local_port)
# do things ...
closeTunnel(sshTunnel)
```
