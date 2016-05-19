# tunnelr tests

# clean up first
system2("pkill", '-f "^ssh -fN"')
t1 = tunnel(.remote_server, .server_username)
expect_equal(class(t1), "tunnel")
expect_error(tunnel(.remote_server, .server_username, local_port = 3306))
expect_true(closeTunnel(t1))
expect_equal(closeTunnel(t1), NA)
