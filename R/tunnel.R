# ssh tunneling from R

portOpen = function(n) {
  flags = paste0("-tnl | grep :", n, " | wc -l")
  x = system2("netstat", flags, stdout = T)
  as.numeric(x) == 0
}

windowsTunnel = function(remote_server, server_username,
                         remote_port = 3306, local_port = 9000) {
  "start plink -N -ssh wm177874@projpet.rit.albany.edu -L 9000:projpet.rit.albany.edu:3306"
  flags = paste0("start plink -N -ssh ", server_username, "@",
                 remote_server, " -L ", local_port, ":",
                 remote_server, ":", remote_port)
  x = system2("ssh", flags)
  if (x != 0) stop("SSH failed.")
  con = list(remote_server = remote_server,
             server_username = server_username,
             remote_port = remote_port,
             local_port = local_port)
  class(con) = "tunnel"
  con
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
  if (.Platform$OS.type == "unix") {
    if (!portOpen(local_port)) stop("Port is already in use.")
    flags = paste0("-fN -L ", local_port, ":localhost:",
                   remote_port, " ", server_username,
                   "@", remote_server,
                   ' -o "ExitOnForwardFailure yes"')
    x = system2("ssh", flags)
    if (x != 0) stop("SSH failed.")
    con = list(remote_server = remote_server,
               server_username = server_username,
               remote_port = remote_port,
               local_port = local_port)
    class(con) = "tunnel"
    con
  } else {
    windowsTunnel(remote_server, server_username, remote_port,
                  local_port)
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
  flags = paste0('-ef "^ssh -fN -L ', con$local_port, '"')
  x = system2("pkill", flags)
  if (x == 0) {
    T
  } else if (x == 1) {
    NA
  } else {
    F
  }
}
