///|
/// 标准Merkle树操作示例
/// 本文件展示了如何使用Merkle树进行标准操作，如创建树、验证证明等

///|
/// 为字符串数组创建Merkle树
pub fn create_standard_string_tree(strings : Array[String]) -> MerkleTree[String] {
  // 定义字符串的叶子哈希函数
  let leaf_hash = fn(s : String) -> HexString {
    // 使用标准哈希函数
    standard_leaf_hash(abi_encode(["string"], [s], fn(s : String) -> String { s }))
  }
  
  // 创建树（node_hash是可选参数，会使用默认值standard_node_hash）
  create_tree(strings, leaf_hash)
}

///|
/// 为整数数组创建Merkle树
pub fn create_standard_int_tree(numbers : Array[Int]) -> MerkleTree[Int] {
  // 定义整数的叶子哈希函数
  let leaf_hash = fn(n : Int) -> HexString {
    // 使用标准哈希函数
    standard_leaf_hash(abi_encode(["uint256"], [n.to_string()], fn(s : String) -> String { s }))
  }
  
  // 创建树
  create_tree(numbers, leaf_hash)
}

///|
/// 验证Merkle证明
pub fn verify_standard_proof[T : Eq + Hash](
  value : T, 
  proof : Array[HexString], 
  root : HexString, 
  leaf_hash : LeafHash[T]
) -> Bool {
  // 使用标准节点哈希验证（node_hash是可选参数）
  verify_with_root(value, proof, root, leaf_hash)
}

///|
/// 验证多重Merkle证明
pub fn verify_standard_multi_proof[T : Eq + Hash](
  multi_proof : MultiProof[T], 
  root : HexString, 
  leaf_hash : LeafHash[T]
) -> Bool {
  // 使用标准节点哈希验证（node_hash是可选参数）
  verify_multi_with_root(multi_proof, root, leaf_hash)
}
