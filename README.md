# tunnelr
Control SSH tunneling in R (only for Mac and Linux for now)

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

To enter an SSH password from a GUI you will need `ssh-askpass` installed. To securely login without entering a password (thus not requiring `ssh-askpass`), follow [these instructions](http://www.thegeekstuff.com/2008/11/3-steps-to-perform-ssh-login-without-password-using-ssh-keygen-ssh-copy-id/).
