///|
/// 简单的字符串哈希函数
pub fn hash_string(s : String) -> HexString {
  keccak256(abi_encode(["string"], [s], fn(s : String) -> String { s }))
}

///|
/// 创建一个字符串Merkle树
pub fn create_string_tree(values : Array[String]) -> MerkleTree[String] {
  create_tree(values, hash_string)
}

///|
/// 验证字符串是否在Merkle树中
pub fn verify_string_in_tree(tree : MerkleTree[String], value : String, proof : Array[HexString]) -> Bool {
  verify(tree, value, proof)
}

///|
/// 整数哈希函数
pub fn hash_int(n : Int) -> HexString {
  keccak256(abi_encode(["uint256"], [n.to_string()], fn(s : String) -> String { s }))
}

///|
/// 创建一个整数Merkle树
pub fn create_int_tree(values : Array[Int]) -> MerkleTree[Int] {
  create_tree(values, hash_int)
}

///|
/// 验证整数是否在Merkle树中
pub fn verify_int_in_tree(tree : MerkleTree[Int], value : Int, proof : Array[HexString]) -> Bool {
  verify(tree, value, proof)
}
