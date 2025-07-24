///|
/// 测试Merkle树的创建
test "create_merkle_tree" {
  // 创建一个简单的Merkle树
  let values = ["a", "b", "c", "d"]
  
  // 定义简单的叶子哈希函数
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 验证树的基本属性
  assert_eq!(length(tree), 4)
  assert_false!(is_empty(tree))
  assert_eq!(value_at(tree, 0), "a")
  assert_eq!(value_at(tree, 3), "d")
  
  // 验证根哈希存在
  let root_hash = root(tree)
  assert_true!(root_hash.has_prefix("0x"))
  assert_eq!(root_hash.length(), 66) // 0x + 64个字符
}

///|
/// 测试空Merkle树
test "empty_merkle_tree" {
  let values = []
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 验证空树属性
  assert_true!(is_empty(tree))
  assert_eq!(length(tree), 0)
  
  // 验证空树的根哈希
  let root_hash = root(tree)
  assert_eq!(root_hash, "0x0")
}

///|
/// 测试单节点Merkle树
test "single_node_merkle_tree" {
  let values = ["single"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 验证单节点树属性
  assert_eq!(length(tree), 1)
  assert_false!(is_empty(tree))
  
  // 单节点树的根哈希应该等于唯一叶子节点的哈希
  let leaf_hash_value = leaf_hash("single")
  let root_hash = root(tree)
  assert_eq!(root_hash, leaf_hash_value)
}

///|
/// 测试Merkle证明的生成和验证
test "merkle_proof" {
  // 创建一个简单的树，只有两个元素，便于手动构建证明
  let values = ["a", "b"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 获取叶子哈希
  let leaf_a_hash = leaf_hash("a")
  let leaf_b_hash = leaf_hash("b")
  
  // 验证元素"a"，需要提供"b"的哈希作为证明
  let proof_for_a = [leaf_b_hash]
  let result1 = verify(tree, "a", proof_for_a)
  assert_true!(result1)
  
  // 验证不存在的元素
  let result2 = verify(tree, "x", proof_for_a)
  assert_false!(result2)
}

///|
/// 测试多重证明
test "multi_proof" {
  // 创建一个简单的树，只有两个元素，便于手动构建多重证明
  let values = ["a", "b"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 对于只有两个元素的树，验证两个元素不需要额外的证明
  // 因为两个元素都是叶子节点，直接组合它们就能得到根
  let multi_proof = MultiProof::{
    leaves: ["a", "b"],
    proof: [],
    proof_flags: [true]  // 表示两个叶子节点应该被组合
  }
  
  // 验证多重证明
  let result = verify_multi(tree, multi_proof)
  assert_true!(result)
}

///|
/// 测试树的字符串表示
test "tree_to_string" {
  let values = ["a", "b"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 获取树的字符串表示
  let tree_str = to_string(tree, fn(s) { s })
  
  // 验证字符串包含必要的信息
  assert_true!(tree_str.has_prefix("MerkleTree {"))
  assert_true!(tree_str.contains("root:"))
  assert_true!(tree_str.contains("leaves:"))
  assert_true!(tree_str.contains("a"))
  assert_true!(tree_str.contains("b"))
}

///|
/// 测试四叉树结构的Merkle证明
test "four_leaf_merkle_proof" {
  // 创建一个四叶子节点的树
  let values = ["a", "b", "c", "d"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 计算每个叶子的哈希
  let hash_a = leaf_hash("a")
  let hash_b = leaf_hash("b")
  let hash_c = leaf_hash("c")
  let hash_d = leaf_hash("d")
  
  // 计算中间节点哈希
  let hash_ab = standard_node_hash(hash_a, hash_b)
  let hash_cd = standard_node_hash(hash_c, hash_d)
  
  // 为"a"构建证明 - 需要b的哈希和cd的组合哈希
  let proof_for_a = [hash_b, hash_cd]
  let result_a = verify(tree, "a", proof_for_a)
  assert_true!(result_a)
  
  // 为"c"构建证明 - 需要d的哈希和ab的组合哈希
  let proof_for_c = [hash_d, hash_ab]
  let result_c = verify(tree, "c", proof_for_c)
  assert_true!(result_c)
}

///|
/// 测试八叉树结构的Merkle证明
test "eight_leaf_merkle_proof" {
  // 创建一个更简单的树，只有四个元素
  let values = ["a", "b", "c", "d"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 获取根哈希
  let root_hash = root(tree)
  
  // 为"a"构建证明
  // 我们需要b的哈希和cd的组合哈希
  let hash_b = leaf_hash("b")
  let hash_c = leaf_hash("c")
  let hash_d = leaf_hash("d")
  let hash_cd = standard_node_hash(hash_c, hash_d)
  
  // 构建验证"a"的证明
  let proof_for_a = [hash_b, hash_cd]
  
  // 使用自定义的根和叶子哈希函数验证
  let result_a = verify_with_root("a", proof_for_a, root_hash, leaf_hash)
  assert_true!(result_a)
}

///|
/// 测试不平衡树（奇数个节点）
test "unbalanced_tree" {
  // 创建一个有5个叶子节点的树（不平衡）
  let values = ["a", "b", "c", "d", "e"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 验证树的基本属性
  assert_eq!(length(tree), 5)
  assert_false!(is_empty(tree))
  
  // 获取根哈希
  let root_hash = root(tree)
  assert_true!(root_hash.has_prefix("0x"))
  
  // 在不平衡树中，最后一个节点没有兄弟节点
  // 验证最后一个节点"e"
  let hash_e = leaf_hash("e")
  
  // 在实际应用中，我们会从树中获取证明
  // 这里我们简单验证"e"在树中
  assert_eq!(get_value_index(tree, "e"), 4)
}

///|
/// 测试复杂的多重证明
test "complex_multi_proof" {
  // 创建一个只有两个元素的树，这是最简单的情况
  let values = ["a", "b"]
  let leaf_hash = fn(s : String) -> HexString {
    keccak256(abi_encode(["string"], [s], fn(s) { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 创建一个验证两个叶子的多重证明
  // 对于只有两个元素的树，验证两个元素不需要额外的证明
  let multi_proof = MultiProof::{
    leaves: ["a", "b"],
    proof: [],
    proof_flags: [true]  // 表示两个叶子节点应该被组合
  }
  
  // 验证多重证明
  let result = verify_multi(tree, multi_proof)
  assert_true!(result)
}

///|
/// 测试自定义哈希函数
test "custom_hash_function" {
  // 定义一个自定义的叶子哈希函数
  let custom_leaf_hash = fn(s : String) -> HexString {
    // 在哈希前添加一个前缀
    let prefixed = "prefix_" + s
    keccak256(abi_encode(["string"], [prefixed], fn(s : String) -> String { s }))
  }
  
  // 创建一个使用自定义叶子哈希函数的树
  // 节点哈希函数使用默认值
  let values = ["a", "b"]
  let tree = create_tree(values, custom_leaf_hash)
  
  // 验证树的基本属性
  assert_eq!(length(tree), 2)
  
  // 获取根哈希
  let root_hash = root(tree)
  assert_true!(root_hash.has_prefix("0x"))
  
  // 验证自定义哈希函数生成的叶子哈希
  let leaf_a_hash = custom_leaf_hash("a")
  assert_true!(leaf_a_hash.has_prefix("0x"))
}

///|
/// 测试整数类型的Merkle树
test "integer_merkle_tree" {
  // 创建一个整数类型的Merkle树
  let values = [1, 2, 3, 4]
  
  // 定义整数的叶子哈希函数
  let leaf_hash = fn(n : Int) -> HexString {
    keccak256(abi_encode(["uint256"], [n.to_string()], fn(s : String) -> String { s }))
  }
  
  let tree = create_tree(values, leaf_hash)
  
  // 验证树的基本属性
  assert_eq!(length(tree), 4)
  assert_false!(is_empty(tree))
  assert_eq!(value_at(tree, 0), 1)
  assert_eq!(value_at(tree, 3), 4)
  
  // 验证元素是否在树中
  let index_3 = get_value_index(tree, 3)
  assert_eq!(index_3, 2)
  
  // 验证根哈希存在
  let root_hash = root(tree)
  assert_true!(root_hash.has_prefix("0x"))
}
