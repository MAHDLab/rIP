test_that("proxycheck works", {
  if (Sys.getenv("PROXYCHECK_API_KEY") != "") {
    val <- proxycheck("8.8.8.8")
    expect_equal(val[["status"]], "ok")
    expect_equal(val[[2]][["proxy"]], "no")
  }
})

test_that("getipintel works", {
  if (Sys.getenv("GETIPINTEL_CONTACT_INFO") != "") {
    val <- getipintel("8.8.8.8")
    expect_equal(val[["status"]], "success")
    expect_equal(val[["result"]], "0")
  }
})

test_that("iphub works", {
  if (Sys.getenv("IPHUB_API_KEY") != "") {
    val <- iphub_check("8.8.8.8")
    expect_equal(val[["block"]], 1)
    expect_equal(val[["isp"]], "GOOGLE")
  }
})
