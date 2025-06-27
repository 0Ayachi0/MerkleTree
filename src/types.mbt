///|
/// 多重证明结构
pub(all) struct MultiProof[T] {
  /// 需要证明的叶子节点
  leaves : Array[T]
  /// 证明所需的哈希值
  proof : Array[HexString]
  /// 证明标记，用于多元素证明的路径标记
  proof_flags : Array[Bool]
}

///|
/// Merkle树数据
pub(all) struct MerkleTreeData[T] {
  /// 树节点哈希数组
  tree : Array[HexString]
  /// 叶子节点值数组
  values : Array[T]
  /// 值与树索引的映射
  value_map : Array[TreeValue[T]]
  /// 根哈希
  root : HexString
}

///|
/// 树中的值与索引映射
pub(all) struct TreeValue[T] {
  /// 存储的实际值
  value : T
  /// 在树数组中的索引位置
  tree_index : Int
}

///|
/// 基本Merkle树实现
pub(all) struct MerkleTreeImpl[T] {
  /// 树节点哈希数组
  tree : Array[HexString]

  /// 值与树索引的映射
  values : Array[TreeValue[T]]

  /// 叶子哈希函数
  leaf_hash : (T) -> HexString

  /// 节点哈希函数(可选)
  node_hash : (HexString, HexString) -> HexString

  /// 哈希查找表(将哈希值映射到值索引)
  hash_lookup : @hashmap.T[HexString, Int]
}

///|
/// Merkle树实现
/// 支持标准操作：创建树、获取证明、验证证明等
pub(all) struct MerkleTree[T] {
  /// 树的数据
  data : MerkleTreeData[T]
  /// 叶子哈希函数
  leaf_hash : LeafHash[T]
  /// 节点哈希函数
  node_hash : NodeHash
}
