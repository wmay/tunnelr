# ssh tunneling from R

portAvailable = function(n) {
  if (.Platform$OS.type == "unix") {
    ports = system2("netstat", "-tnl", stdout = T)
  } else {
    ports = shell("netstat -an", intern = T)
  }
  length(grep(paste0(":", n, " "), ports)) == 0
}

findPutty = function() {
  # look in C:\Program Files...
  folders = shell("dir C:", intern = T)
  pfolders = folders[grep("Program Files", folders)]
  plink_path = NA
  for (folder in pfolders) {
    cmd = paste0("dir C:/", folder)
    files = shell(cmd, intern = T)
    include_plink = any(grepl("plink", files))
    if (include_plink) {
      plink_path = folder
      break
    }
  }
  if (is.na(plink_path)) stop("Path to plink not found.")
  plink_path
}

#' Set up SSH tunneling
#' 
#' @param remote_server The URL or IP address of the remote server.
#' @param server_username Username to log into the remote server.
#' @param remote_port The port to connect to on the remote
#'   server. 3306 is the default port used by MySQL.
#' @param local_port The port to connect to on the local machine.
#' @return A connection object of class "tunnel".
#' @examples
#' \dontrun{
#' sshTunnel = tunnel(remote_server, server_username,
#'                    remote_port, local_port)
#' closeTunnel(sshTunnel)
#' }
#' @export
tunnel = function(remote_server, server_username,
                  remote_port = 3306, local_port = 9000) {
  if (!portAvailable(local_port)) stop("Port is already in use.")
  if (.Platform$OS.type == "unix") {
    flags = paste0("-fN -L ", local_port, ":localhost:",
                   remote_port, " ", server_username,
                   "@", remote_server,
                   ' -o "ExitOnForwardFailure yes"')
    x = system2("ssh", flags)
  } else {
    "start plink -N -ssh wm177874@projpet.rit.albany.edu -L 9000:projpet.rit.albany.edu:3306"
    plink_path = findPutty()
    cmd = paste0("start ", plink_path, "-N -ssh ",
                 server_username, "@",
                 remote_server, " -L ", local_port, ":",
                 remote_server, ":", remote_port)
    x = shell(cmd)
    # wait until process is running
    running = F
    while (!running) {
      sleep(.5)
      running = !portAvailable(n)
    }
    x
  }
  if (x != 0) stop("SSH failed.")
  con = list(remote_server = remote_server,
             server_username = server_username,
             remote_port = remote_port,
             local_port = local_port)
  class(con) = "tunnel"
  con
}

#' Determine whether a tunnel opened by tunnelr is running
#' 
#' @param con An object of class "tunnel" returned by \code{tunnel()}.
#' @return \code{TRUE} if the SSH tunnel is open, \code{FALSE}
#'   otherwise.
#' @examples
#' \dontrun{
#' sshTunnel = tunnel(remote_server, server_username,
#'                    remote_port, local_port)
#' tunnelOpen(sshTunnel) # returns TRUE
#' closeTunnel(sshTunnel)
#' tunnelOpen(sshTunnel) # returns FALSE
#' }
#' @export
tunnelOpen = function(con) {
  # check to see if the tunnel is open
  if (.Platform$OS.type == "unix") {
    flags = paste0('-f "^ssh -fN -L ', con$local_port, '"')
    x = system2("pgrep", flags, stdout = T)
  } else {
    cmd = paste0('tasklist /fi "windowtitle eq tunnelr',
                 con$local_port, '"')
    x = shell(cmd, intern = T)
  }
  if (length(x) > 0) {
    T
  } else {
    F
  }
}

#' Close an SSH tunnel
#' 
#' @param con An object of class "tunnel" returned by \code{tunnel()}.
#' @return \code{TRUE} if the function closes the tunnel associated
#'   with \code{con}, \code{NA} if there was no tunnel to close, or
#'   \code{FALSE} if the tunnel could not be closed.
#' @examples
#' \dontrun{
#' sshTunnel = tunnel(remote_server, server_username,
#'                    remote_port, local_port)
#' closeTunnel(sshTunnel)
#' }
#' @export
closeTunnel = function(con) {
  if (.Platform$OS.type == "unix") {
    flags = paste0('-ef "^ssh -fN -L ', con$local_port, '"')
    x = system2("pkill", flags)
  } else {
    cmd = paste0('taskkill /fi "windowtitle eq tunnelr',
                 con$local_port, '"')
    x = shell(cmd)
  }
  if (x == 0) {
    T
  } else if (x == 1 || x == 128) {
    NA
  } else {
    F
  }
}
