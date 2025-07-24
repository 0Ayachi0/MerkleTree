///|
/// 从叶子元素构建Merkle树
pub fn[T : Eq + Hash] create_tree(
  values : Array[T],
  leaf_hash : LeafHash[T],
  node_hash~ : NodeHash = standard_node_hash
) -> MerkleTree[T] {
  // 计算每个值的哈希
  let leaves = []
  let value_map = []
  let mut i = 0
  for value in values {
    // 哈希值
    let hash = leaf_hash(value)
    leaves.push(hash)

    // 关联元素与索引
    value_map.push(TreeValue::{ value, tree_index: i })
    i = i + 1
  }

  // 构建树
  let tree = build_merkle_tree(leaves, node_hash)
  let temp = if tree.length() > 0 { tree[tree.length() - 1] } else { "0x0" }
  // 创建树的数据结构
  let data = MerkleTreeData::{ values, tree, value_map, root: temp }
  { data, leaf_hash, node_hash }
}

///|
/// 获取Merkle树的根哈希
pub fn[T : Eq + Hash] root(tree : MerkleTree[T]) -> HexString {
  tree.data.root
}

///|
/// 获取树中的叶子节点数量
pub fn[T : Eq + Hash] length(tree : MerkleTree[T]) -> Int {
  tree.data.values.length()
}

///|
/// 验证树是否为空
pub fn[T : Eq + Hash] is_empty(tree : MerkleTree[T]) -> Bool {
  tree.data.values.length() == 0
}

///|
/// 获取指定索引位置的叶子节点
pub fn[T : Eq + Hash] value_at(tree : MerkleTree[T], index : Int) -> T {
  if index < 0 || index >= tree.data.values.length() {
    abort("Index out of bounds")
  }
  tree.data.values[index]
}

///|
/// 获取值对应的索引
pub fn[T : Eq + Hash] get_value_index(tree : MerkleTree[T], value : T) -> Int {
  // 在value_map中查找值和索引的映射
  for tree_value in tree.data.value_map {
    if tree_value.value == value {
      return tree_value.tree_index
    }
  }
  -1 // 未找到
}

///|
/// 验证单个叶子节点的Merkle证明
pub fn[T : Eq + Hash] verify(
  tree : MerkleTree[T],
  value : T,
  proof : Array[HexString]
) -> Bool {
  // 计算叶子哈希
  let hash = (tree.leaf_hash)(value)

  // 验证证明
  verify_proof(hash, proof, tree.data.root, tree.node_hash)
}

///|
/// 验证根哈希与提供的证明是否匹配给定的叶子值
pub fn[T : Eq + Hash] verify_with_root(
  value : T,
  proof : Array[HexString],
  root : HexString,
  leaf_hash : LeafHash[T],
  node_hash~ : NodeHash = standard_node_hash
) -> Bool {
  // 计算叶子哈希
  let hash = leaf_hash(value)

  // 验证证明
  verify_proof(hash, proof, root, node_hash)
}

///|
/// 验证多个叶子节点的Merkle证明
pub fn[T : Eq + Hash] verify_multi(
  tree : MerkleTree[T],
  multi_proof : MultiProof[T]
) -> Bool {
  // 验证多重证明
  verify_multi_proof(
    multi_proof.leaves,
    multi_proof.proof,
    multi_proof.proof_flags,
    tree.data.root,
    tree.leaf_hash,
    tree.node_hash,
  )
}

///|
/// 验证多个叶子节点的Merkle证明与指定的根哈希是否匹配
pub fn[T : Eq + Hash] verify_multi_with_root(
  multi_proof : MultiProof[T],
  root : HexString,
  leaf_hash : LeafHash[T],
  node_hash~ : NodeHash = standard_node_hash
) -> Bool {
  // 验证多重证明
  verify_multi_proof(
    multi_proof.leaves,
    multi_proof.proof,
    multi_proof.proof_flags,
    root,
    leaf_hash,
    node_hash,
  )
}

///|
/// 返回树的字符串表示
pub fn[T : Eq + Hash] to_string(
  tree : MerkleTree[T],
  value_to_string : (T) -> String
) -> String {
  let mut result = "MerkleTree {\n"
  result = result + "  root: " + tree.data.root + "\n"
  result = result + "  leaves: [\n"
  let mut i = 0
  while i < tree.data.values.length() {
    result = result + "    " + value_to_string(tree.data.values[i])
    if i < tree.data.values.length() - 1 {
      result = result + ","
    }
    result = result + "\n"
    i += 1
  }
  result = result + "  ]\n"
  result = result + "}"
  result
}

///|
/// 构建哈希层级
/// 从当前层的哈希值计算上一层的哈希值
fn build_layer(
  hashes : Array[HexString],
  node_hash : NodeHash
) -> Array[HexString] {
  let result = []

  // 如果只有一个哈希值，直接返回
  if hashes.length() <= 1 {
    return hashes
  }

  // 两两组合计算上一层的哈希值
  let mut i = 0
  while i < hashes.length() {
    let left = hashes[i]
    let right = if i + 1 < hashes.length() { hashes[i + 1] } else { left }
    result.push(node_hash(left, right))
    i += 2
  }
  result
}

///|
/// 从叶子哈希开始构建完整的Merkle树
pub fn build_merkle_tree(
  leaves : Array[HexString],
  node_hash : NodeHash
) -> Array[HexString] {
  // 如果没有叶子，返回空树
  if leaves.length() == 0 {
    return []
  }

  // 如果只有一个叶子，返回单节点树
  if leaves.length() == 1 {
    return leaves
  }
  let tree = []

  // 从叶子层开始构建
  let mut current_layer = leaves

  // 逐层构建树，直到只剩下根节点
  while current_layer.length() > 1 {
    // 将当前层添加到树中
    current_layer.each(fn(hash) { tree.push(hash) })

    // 构建上一层
    current_layer = build_layer(current_layer, node_hash)
  }

  // 添加根节点
  tree.push(current_layer[0])
  tree
}

///|
/// 获取叶子节点的证明路径
pub fn get_proof(
  leaf : HexString,
  tree : Array[HexString],
  leaf_indexes : @hashmap.T[HexString, Int]
) -> Array[HexString] {
  // 获取叶子在树中的索引
  let mut index = leaf_indexes
    .get(leaf)
    .or_else(fn() {
      abort("Leaf not found in the tree")
      -1
    })
  let proof = []

  // 从叶子层开始，一直到根节点
  let mut layer_index = 0
  let mut layer_size = (tree.length() + 1) / 2
  while layer_size > 1 {
    // 计算同层中的兄弟节点索引
    let sibling_index = if index % 2 == 0 { index + 1 } else { index - 1 }

    // 如果兄弟节点存在于树中，添加到证明中
    if sibling_index < layer_size {
      proof.push(tree[layer_index + sibling_index])
    }

    // 移动到上一层
    index = index / 2
    layer_index += layer_size
    layer_size = (layer_size + 1) / 2
  }
  proof
}

///|
/// 验证单个证明
pub fn verify_proof(
  leaf : HexString,
  proof : Array[HexString],
  root : HexString,
  node_hash : NodeHash
) -> Bool {
  let mut computed_hash = leaf

  // 重新计算根哈希
  for sibling in proof {
    computed_hash = node_hash(computed_hash, sibling)
  }

  // 比较计算出的哈希与根哈希
  computed_hash == root
}

///|
/// 获取多个叶子节点的证明
pub fn[T : Eq + Hash] get_multi_proof(
  leaves : Array[T],
  tree : Array[HexString],
  values : Array[TreeValue[T]]
) -> MultiProof[T] {
  // 准备结果
  let proof = []
  let proof_flags = []

  // 查找每个叶子在树中的索引
  let indexes = []
  for leaf in leaves {
    let mut found = false
    for value in values {
      if value.value == leaf {
        indexes.push(value.tree_index)
        found = true
        break
      }
    }
    if found == false {
      abort("Leaf not found in the tree")
    }
  }

  // 从这些索引生成多重证明
  let proof_hashes = @hashset.new()

  // 计算树层信息
  let mut layer_index = 0
  let mut layer_size = (tree.length() + 1) / 2
  let mut layer_indices = indexes
  while layer_size > 1 {
    let next_layer_indices = []

    // 为当前层的每个索引找到兄弟节点
    for i in layer_indices {
      let sibling_index = if i % 2 == 0 { i + 1 } else { i - 1 }

      // 如果兄弟节点不在我们的索引中，添加到证明中
      if layer_indices.contains(sibling_index) == false &&
        sibling_index < layer_size {
        proof_hashes.add(tree[layer_index + sibling_index])
      }

      // 移动到上一层
      next_layer_indices.push(i / 2)
    }

    // 去除重复的索引
    layer_indices = array_unique(next_layer_indices)

    // 移动到上一层
    layer_index += layer_size
    layer_size = (layer_size + 1) / 2
  }

  // 转换哈希集为数组
  proof_hashes.each(fn(hash) { proof.push(hash) })

  // 创建证明标志，用于多重证明重构
  // 这里需要具体的多重证明重构算法，较复杂

  { leaves, proof, proof_flags }
}

///|
/// 验证多重证明
/// 注意：这是一个复杂的算法，需要维护一个验证队列
pub fn[T] verify_multi_proof(
  leaves : Array[T],
  proof : Array[HexString],
  proof_flags : Array[Bool],
  root : HexString,
  leaf_hash : (T) -> HexString,
  node_hash : NodeHash
) -> Bool {
  // 如果没有叶子，直接失败
  if leaves.length() == 0 {
    return false
  }

  // 如果只有一个叶子，退化为单证明验证
  if leaves.length() == 1 {
    let leaf_hash_str = leaf_hash(leaves[0])
    return verify_proof(leaf_hash_str, proof, root, node_hash)
  }

  // 初始化验证队列，首先添加所有叶子哈希
  let mut hashes = []
  for leaf in leaves {
    hashes.push(leaf_hash(leaf))
  }

  // 处理证明，重建树
  let mut proof_index = 0
  let mut flag_index = 0
  while hashes.length() > 1 {
    let next_hashes = []

    // 处理当前层
    let mut i = 0
    while i < hashes.length() {
      if flag_index < proof_flags.length() && proof_flags[flag_index] {
        // 使用队列中的下一个哈希和它的兄弟组合
        if i + 1 < hashes.length() {
          next_hashes.push(node_hash(hashes[i], hashes[i + 1]))
          i += 2
        } else {
          // 单独的节点，无兄弟
          next_hashes.push(hashes[i])
          i += 1
        }
      } else {
        // 使用队列中的下一个哈希和证明中的下一个哈希组合
        if proof_index < proof.length() {
          next_hashes.push(node_hash(hashes[i], proof[proof_index]))
          proof_index += 1
        } else {
          // 证明不足
          return false
        }
        i += 1
      }
      flag_index += 1
    }

    // 更新队列
    hashes = next_hashes
  }

  // 最终我们应该只剩下根哈希
  return hashes.length() == 1 && hashes[0] == root
}

///|
/// 从树中获取叶子层哈希值
pub fn get_leaves(tree : Array[HexString]) -> Array[HexString] {
  let leaf_count = (tree.length() + 1) / 2
  let leaves = []
  let mut i = 0
  while i < leaf_count {
    leaves.push(tree[i])
    i += 1
  }
  leaves
}

///|
/// 计算树中每个层的节点数
pub fn get_tree_layer_sizes(leaf_count : Int) -> Array[Int] {
  if leaf_count == 0 {
    return [0]
  }
  let layer_sizes = []
  let mut current_size = leaf_count
  while current_size > 0 {
    layer_sizes.push(current_size)
    current_size = (current_size + 1) / 2
    if current_size == 1 {
      layer_sizes.push(1)
      break
    }
  }
  layer_sizes
}

///|
/// 辅助函数：数组去重
fn[T : Eq + Hash] array_unique(arr : Array[T]) -> Array[T] {
  let result = []
  let seen = @hashset.new()
  for item in arr {
    if seen.contains(item) == false {
      result.push(item)
      seen.add(item)
    }
  }
  result
}
