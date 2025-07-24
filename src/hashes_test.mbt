///|
/// 测试keccak256哈希函数
test "keccak256" {
  // 基本功能测试
  let result1 = keccak256(hex_to_bytes("0x1234"))
  assert_true(result1.has_prefix("0x"))
  assert_eq(result1.length(), 66) // 0x + 64个字符（32字节）

  // 相同输入产生相同输出
  let result2 = keccak256(hex_to_bytes("0x1234"))
  assert_eq(result1, result2)

  // 不同输入产生不同输出
  let result3 = keccak256(hex_to_bytes("0x1235"))
  assert_not_eq(result1, result3)

  // 空输入测试
  let result4 = keccak256([])
  assert_true(result4.has_prefix("0x"))
  assert_eq(result4.length(), 66)
}

///|
/// 测试标准叶子哈希函数
test "standard_leaf_hash" {
  // 基本功能测试
  let encoded1 = hex_to_bytes("0xabcdef")
  let result1 = standard_leaf_hash(encoded1)
  assert_true(result1.has_prefix("0x"))
  assert_eq(result1.length(), 66)

  // 相同输入产生相同输出
  let result2 = standard_leaf_hash(encoded1)
  assert_eq(result1, result2)

  // 不同输入产生不同输出
  let encoded2 = hex_to_bytes("0xabcdee")
  let result3 = standard_leaf_hash(encoded2)
  assert_not_eq(result1, result3)

  // 验证确实是双重哈希，而不是单次哈希
  let single_hash = keccak256(encoded1)
  assert_not_eq(result1, single_hash)
}

///|
/// 测试标准节点哈希函数
test "standard_node_hash" {
  // 基本功能测试
  let hash1 = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
  let hash2 = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
  let result1 = standard_node_hash(hash1, hash2)
  assert_true(result1.has_prefix("0x"))
  assert_eq(result1.length(), 66)

  // 相同输入产生相同输出
  let result2 = standard_node_hash(hash1, hash2)
  assert_eq(result1, result2)

  // 输入顺序不影响结果（应排序后哈希）
  let result3 = standard_node_hash(hash2, hash1)
  assert_eq(result1, result3)

  // 不同输入产生不同输出
  let hash3 = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
  let result4 = standard_node_hash(hash1, hash3)
  assert_not_eq(result1, result4)
}

///|
/// 测试ABI编码函数
test "abi_encode" {
  // 基本功能测试
  let types = ["address", "uint256"]
  let values = [
    "0x1234567890123456789012345678901234567890", "1000000000000000000",
  ]
  let result = abi_encode(types, values, fn(s) { s })
  assert_true(result.length() > 0)

  // 相同输入产生相同输出
  let result2 = abi_encode(types, values, fn(s) { s })
  assert_eq(result, result2)

  // 不同输入产生不同输出
  let types2 = ["uint256", "address"]
  let result3 = abi_encode(types2, values, fn(s) { s })
  assert_not_eq(result, result3)

  // 测试空输入
  let empty_result = abi_encode([], [], fn(s) { s })
  assert_eq(empty_result.length(), 0)

  // 测试类型和值数量不匹配的情况
  let result4 = abi_encode(types, [values[0]], fn(s) { s })
  assert_not_eq(result, result4)
}

///|
/// 测试mock_keccak256函数（内部函数）
test "mock_keccak256" {
  // 基本功能测试
  let input = hex_to_bytes("0x1234")
  let result1 = mock_keccak256(input)
  assert_eq(result1.length(), 32) // 应该是32字节（256位）

  // 相同输入产生相同输出
  let result2 = mock_keccak256(input)
  assert_eq(result1, result2)

  // 不同输入应产生不同输出
  let input2 = hex_to_bytes("0x1235")
  let result3 = mock_keccak256(input2)
  assert_not_eq(result1, result3)

  // 空输入测试
  let result4 = mock_keccak256([])
  assert_eq(result4.length(), 32)
}

///|
/// 集成测试：验证完整哈希过程
test "hash_integration" {
  // 创建简单的编码数据
  let types = ["string", "uint256"]
  let values = ["test", "123"]
  let encoded = abi_encode(types, values, fn(s) { s })

  // 计算叶子哈希
  let leaf_hash = standard_leaf_hash(encoded)

  // 计算节点哈希
  let other_hash = keccak256(hex_to_bytes("0xabcdef"))
  let node_hash = standard_node_hash(leaf_hash, other_hash)

  // 验证结果长度
  assert_eq(leaf_hash.length(), 66) // 0x + 64个字符
  assert_eq(node_hash.length(), 66) // 0x + 64个字符

  // 验证叶子哈希和节点哈希不同
  assert_not_eq(leaf_hash, node_hash)
}
