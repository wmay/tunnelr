# ssh tunneling from R

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
tunnel = function(remote_server, server_username,
                  remote_port = 3306, local_port = 9000) {
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
closeTunnel = function(con) {
  flags = paste0('-ef "^ssh -fN -L ', con$local_port, '"')
  ## cat(flags)
  x = system2("pkill", flags)
  print(x)
  if (x == 0) {
    T
  } else if (x == 1) {
    NA
  } else {
    F
  }
}
