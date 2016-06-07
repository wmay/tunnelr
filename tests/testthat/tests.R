# tunnelr tests

# clean up first
closeTunnel(list(local_port = 9000))
## system2("pkill", '-f "^ssh -fN"')
t1 = tunnel(.remote_server, .server_username)
expect_equal(class(t1), "tunnel")
# can't open the same tunnel twice
expect_error(tunnel(.remote_server, .server_username))
expect_true(closeTunnel(t1))
expect_equal(closeTunnel(t1), NA)
