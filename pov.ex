defmodule Pov do
  # 挺有难度, 好玩
	# inspiried from: ejlangev
	# https://www.bilibili.com/video/BV1p3411H7Pn
  
  @typedoc """
  A tree, which is made of a node with several branches
  """
  @type tree :: {any, [tree]}



  @doc """
  Reparent a tree on a selected node.
  """
  @spec from_pov(tree :: tree, node :: any) :: {:ok, tree} | {:error, atom}

  def from_pov(tree, node) do
    case pfrom_pov(tree, node) do
      :nonexistent -> {:error, :nonexistent_target}
      something -> {:ok, something}
    end
  end
  
  defp pfrom_pov({root, children}, root), do: {root, children}
  defp pfrom_pov(tree, node) do
    case path_to(tree, node, []) do   # all the parent node from root to the new root
      nil -> :nonexistent
      path ->
	node_to_root = Enum.reverse(path) |> tl()
	{node,
	 find_children(tree, path)
	 ++ [{elem(pfrom_pov(tree, hd(node_to_root)), 0), elem(pfrom_pov(tree, hd(node_to_root)), 1)
	 -- [{node, find_children(tree, path)}]}]         # recursion, without siblings
	}
    end	
  end

  @doc """
  Finds a path between two nodes
  """
  @spec path_between(tree :: tree, from :: any, to :: any) :: {:ok, [any]} | {:error, atom}
  def path_between(tree, from, to) do
    new_tree = pfrom_pov(tree, from)
    if new_tree != :nonexistent do
      case path_to(new_tree, to, []) do
	nil -> {:error, :nonexistent_destination}
	path -> {:ok, path}
      end
    else
      {:error, :nonexistent_source}
    end
  end


  @doc """
  path from root to node
  a = {1, [{2, []}, {3, [{4, []}, {5, []}]}]}
  path_to(a, 5, []) = [1, 3, 5]
  path_to(a, 0, []) = nil
  """
  defp path_to({node, _children}, node, acc), do: acc ++ [node]
  defp path_to({node, children}, to_search, acc) do
    Enum.find_value(children, fn c ->
      case path_to(c, to_search, acc ++ [node]) do
	[] -> nil
	path -> path
      end
    end)
  end

  defp find_children(tree, [_node_to_find]) when is_tuple(tree), do: elem(tree, 1)
  defp find_children(nil, _), do: []
  defp find_children(tree, [_hh |[h | t]]) do  # ht is path to node
    Enum.find(elem(tree, 1), fn x -> elem(x, 0) == h end)
    |> find_children([h | t])
  end
end
