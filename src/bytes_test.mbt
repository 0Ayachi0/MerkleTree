///|
/// 测试字符串切片功能
test "string_slice" {
  // 基本切片操作
  assert_eq!(string_slice("hello", 0, end=2), "he")
  assert_eq!(string_slice("hello", 1, end=4), "ell")

  // 省略结束索引，切到末尾
  assert_eq!(string_slice("hello", 2), "llo")

  // 空字符串
  assert_eq!(string_slice("", 0), "")

  // 单字符
  assert_eq!(string_slice("x", 0, end=1), "x")
}

///|
/// 测试十六进制字符串转换为字节数组
test "hex_to_bytes" {
  // 基本转换
  let bytes1 = hex_to_bytes("0x1234")
  assert_eq!(bytes1.length(), 2)
  assert_eq!(bytes1[0], 0x12)
  assert_eq!(bytes1[1], 0x34)

  // 不带0x前缀
  let bytes2 = hex_to_bytes("abcd")
  assert_eq!(bytes2.length(), 2)
  assert_eq!(bytes2[0], 0xab)
  assert_eq!(bytes2[1], 0xcd)

  // 奇数长度（应该前置补0）
  let bytes3 = hex_to_bytes("0xf")
  assert_eq!(bytes3.length(), 1)
  assert_eq!(bytes3[0], 0x0f)

  // 空字符串
  let bytes4 = hex_to_bytes("")
  assert_eq!(bytes4.length(), 0)
}

///|
/// 测试字节数组转换为十六进制字符串
test "bytes_to_hex" {
  // 基本转换
  assert_eq!(bytes_to_hex([0x12, 0x34]), "0x1234")

  // 空数组
  assert_eq!(bytes_to_hex([]), "0x")

  // 单字节
  assert_eq!(bytes_to_hex([0xff]), "0xff")

  // 多字节
  assert_eq!(bytes_to_hex([0x01, 0x23, 0x45, 0x67]), "0x01234567")
}

///|
/// 测试连接字节数组
test "concat_bytes" {
  // 基本连接
  let result1 = concat_bytes([[0x12, 0x34], [0x56, 0x78]])
  assert_eq!(result1.length(), 4)
  assert_eq!(result1, [0x12, 0x34, 0x56, 0x78])

  // 连接空数组
  let result2 = concat_bytes([[0x12, 0x34], [], [0x56]])
  assert_eq!(result2.length(), 3)
  assert_eq!(result2, [0x12, 0x34, 0x56])

  // 全部为空数组
  let result3 = concat_bytes([[], [], []])
  assert_eq!(result3.length(), 0)

  // 单数组
  let result4 = concat_bytes([[0x12, 0x34]])
  assert_eq!(result4.length(), 2)
  assert_eq!(result4, [0x12, 0x34])
}

///|
/// 测试函数别名
test "alias_functions" {
  // 测试to_hex
  assert_eq!(to_hex([0x12, 0x34]), "0x1234")

  // 测试to_bytes
  let result = to_bytes("0xabcd")
  assert_eq!(result.length(), 2)
  assert_eq!(result[0], 0xab)
  assert_eq!(result[1], 0xcd)

  // 测试concat
  let result2 = concat([[0x12], [0x34]])
  assert_eq!(result2.length(), 2)
  assert_eq!(result2, [0x12, 0x34])
}

///|
/// 测试字节数组比较
test "compare_bytes" {
  // 相等
  assert_eq!(compare([0x12, 0x34], [0x12, 0x34]), 0)

  // 第一个大于第二个
  assert_eq!(compare([0x12, 0x35], [0x12, 0x34]), 1)

  // 第一个小于第二个
  assert_eq!(compare([0x12, 0x33], [0x12, 0x34]), -1)

  // 长度不同
  assert_eq!(compare([0x12, 0x34, 0x56], [0x12, 0x34]), 1)
  assert_eq!(compare([0x12], [0x12, 0x34]), -1)

  // 空数组
  assert_eq!(compare([], []), 0)
  assert_eq!(compare([], [0x12]), -1)
  assert_eq!(compare([0x12], []), 1)
}

///|
/// 测试十六进制字符到数值的转换
test "parse_hex_byte" {
  assert_eq!(parse_hex_byte("00"), 0)
  assert_eq!(parse_hex_byte("09"), 9)
  assert_eq!(parse_hex_byte("0a"), 10)
  assert_eq!(parse_hex_byte("0f"), 15)
  assert_eq!(parse_hex_byte("10"), 16)
  assert_eq!(parse_hex_byte("ff"), 255)
  assert_eq!(parse_hex_byte("Ff"), 255)
  assert_eq!(parse_hex_byte("FF"), 255)
}

///|
/// 测试有效十六进制字符串检查
test "is_valid_hex" {
  // 有效十六进制
  assert_true!(is_valid_hex("0x1234"))
  assert_true!(is_valid_hex("1234"))
  assert_true!(is_valid_hex("0xabcd"))
  assert_true!(is_valid_hex("0xABCD"))
  assert_true!(is_valid_hex("0x1A2B3C4D"))

  // 无效十六进制
  assert_false!(is_valid_hex("0x12G4")) // 含有非十六进制字符G
  assert_false!(is_valid_hex("0xZZ")) // 含有非十六进制字符Z
  assert_false!(is_valid_hex("")) // 空字符串

  // 边界情况
  assert_true!(is_valid_hex("0")) // 单个数字
  assert_true!(is_valid_hex("a")) // 单个字母
  assert_true!(is_valid_hex("0x0")) // 0x后跟单个数字
}
