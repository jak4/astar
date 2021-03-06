require 'set'
class AStar # subclass me!
  protected

  # override neighbors, edge_cost, and heuristic for your problem domain.
  def neighbors( node )
    [] # should return a list of nodes (or any enumerable, really)
  end

  def edge_cost( from, to ) # real cost between nodes
    1
  end

  def heuristic( from ) # estimated cost to goal
    0
  end

  def start_cost
    0 # If you want to use something other than integers, you may need to override start_cost
  end

  def visited( node )
    # noop, override as a hook
  end

  # ---------------
  # Convenience methods. Usually you won't need to override them.

  def is_goal?( node )
    goal === node
  end

  def known_cost( node )
    @known_cost[ node ]
  end

  def estimated_cost( node )
    @known_cost[node] + @memoized_heuristic[node]
  end

  attr_reader :start, :goal
  def initialize( start, goal )
    @start, @goal = start, goal
    @open = [start]
    @parent = Hash.new
    @closed = Set.new
    @known_cost = {start => start_cost}

    @memoized_heuristic = Hash.new{|hash, node| hash[node] = heuristic(node) }
  end

  public

  # ---------------
  # The actual algorithm

  def search
    loop do
      node = cheapest_open_node
      return nil if node.nil?

      visited(node)

      return path_to(node) if is_goal?(node)

      close( node )
      search_neighbors( node )
    end
  end

  private

  def close( node )
    @closed << node
    @open.delete(node)
  end

  def maybe_assign_parent( parent, child )
    child_cost = known_cost(parent) + edge_cost( parent , child )

    if ! known_cost(child) or known_cost(child) > child_cost # This path seems better than the best known to that node
      @known_cost[child] = child_cost
      @parent[child] = parent

      @open << child unless @open.include?(child)
      @open = @open.sort_by{ |n| estimated_cost( n ) }
    end
  end

  def search_neighbors( node )
    neighbors(node).each do |neighbor|
      next if @closed.include?(neighbor)
      maybe_assign_parent( node, neighbor )
    end
  end

  def cheapest_open_node
    @open.first
  end

  def path_to(node)
    path = []
    while node do
      path = [node] + path
      node = @parent[node]
    end
    path
  end

end
