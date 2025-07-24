///|
/// 表示字节数组的类型
pub typealias Array[UInt16] as HexBytes

///|
/// 表示十六进制字符串的类型
pub typealias String as HexString

///|
pub fn string_slice(s : String, start : Int, end~ : Int = -1) -> String {
  let actual_end = if end < 0 { s.length() } else { end }

  // 检查索引范围
  if start < 0 ||
    start > s.length() ||
    actual_end < start ||
    actual_end > s.length() {
    abort("Invalid slice indices")
    return ""
  }
  let mut result = ""
  let mut i = start
  while i < actual_end {
    result = result + s.char_at(i).to_string()
    i += 1
  }
  result
}

///|
/// 将十六进制字符串转换为字节数组
pub fn hex_to_bytes(hex : String) -> HexBytes {
  // 删除前缀"0x"
  let hex = if hex.has_prefix("0x") { string_slice(hex, 2) } else { hex }

  // 确保长度为偶数
  let hex = if hex.length() % 2 == 1 { "0" + hex } else { hex }
  let bytes = []
  let mut i = 0
  while i < hex.length() {
    let hex_byte = string_slice(hex, i, end=i + 2)
    let byte = parse_hex_byte(hex_byte)
    bytes.push(byte)
    i += 2
  }
  bytes
}

///|
/// 将字节数组转换为十六进制字符串
pub fn bytes_to_hex(bytes : HexBytes) -> HexString {
  let mut hex = "0x"
  for byte in bytes {
    hex = hex + byte_to_hex(byte)
  }
  hex
}

///|
/// 连接多个字节数组
pub fn concat_bytes(bytes_list : Array[HexBytes]) -> HexBytes {
  let result = []
  bytes_list.each(fn(bytes) { bytes.each(fn(b) { result.push(b) }) })
  result
}

///|
/// 将字节数组转换为十六进制字符串
pub fn to_hex(value : HexBytes) -> HexString {
  bytes_to_hex(value)
}

///|
/// 将十六进制字符串转换为字节数组
pub fn to_bytes(value : HexString) -> HexBytes {
  hex_to_bytes(value)
}

///|
/// 连接多个字节数组
pub fn concat(values : Array[HexBytes]) -> HexBytes {
  concat_bytes(values)
}

///|
/// 比较两个字节数组的大小
/// 返回值:
/// - 如果a > b，返回1
/// - 如果a < b，返回-1
/// - 如果a = b，返回0
pub fn compare(a : HexBytes, b : HexBytes) -> Int {
  let hex_a = bytes_to_hex(a)
  let hex_b = bytes_to_hex(b)
  if hex_a == hex_b {
    return 0
  }

  // 比较长度
  if a.length() != b.length() {
    return if a.length() > b.length() { 1 } else { -1 }
  }

  // 逐字节比较
  let mut i = 0
  while i < a.length() {
    if a[i] != b[i] {
      return if a[i] > b[i] { 1 } else { -1 }
    }
    i += 1
  }
  0
}

// 辅助函数

///|
/// 将单个字节转换为两位十六进制字符串
pub fn byte_to_hex(byte : UInt16) -> String {
  // 先转换为Int进行模运算，然后转回UInt16
  let byte_val = byte.to_int() % 256

  // 计算高位和低位
  let high = byte_val / 16
  let low = byte_val % 16
  digit_to_hex_char(high.to_uint16()) + digit_to_hex_char(low.to_uint16())
}

///|
fn digit_to_hex_char(digit : UInt16) -> String {
  if digit < 10 {
    digit.to_string()
  } else {
    match digit {
      10 => "a"
      11 => "b"
      12 => "c"
      13 => "d"
      14 => "e"
      15 => "f"
      _ => abort("Invalid hex digit")
    }
  }
}

///|
/// 解析两位十六进制字符串为字节
pub fn parse_hex_byte(hex : String) -> UInt16 {
  let high = hex_char_to_value(hex.char_at(0))
  let low = hex_char_to_value(hex.char_at(1))
  high * 16 + low
}

///|
/// 将十六进制字符转换为数值
pub fn hex_char_to_value(c : Char) -> UInt16 {
  if c >= '0' && c <= '9' {
    (c.to_int() - '0'.to_int()).to_uint16()
  } else if c >= 'a' && c <= 'f' {
    (c.to_int() - 'a'.to_int() + 10).to_uint16()
  } else if c >= 'A' && c <= 'F' {
    (c.to_int() - 'A'.to_int() + 10).to_uint16()
  } else {
    abort("Invalid hex character: " + c.to_string())
    0
  }
}

///|
/// 检查字符串是否为有效的十六进制字符串
pub fn is_valid_hex(s : String) -> Bool {
  // 移除可能的0x前缀
  let hex = if s.has_prefix("0x") { string_slice(s, 2) } else { s }

  // 空字符串不是有效的十六进制字符串
  if hex.length() == 0 {
    return false
  }

  // 检查每个字符是否为有效的十六进制字符
  let mut i = 0
  while i < hex.length() {
    let c = hex.char_at(i)
    if (
        (c >= '0' && c <= '9') ||
        (c >= 'a' && c <= 'f') ||
        (c >= 'A' && c <= 'F')
      ) ==
      false {
      return false
    }
    i += 1
  }
  true
}
