class Colorizer
  PRIORITY_COLORS = {
      :a => '#FF0000',
      :b => '#FF7B00',
      :c => '#FFCC00',
      :d => '#0AFFE3',
      :e => '#9AFF02',
      :default => '#2D2D2D'
  }

  def initialize(todo)
    @todo = todo
  end

  def color
    priority_color
  end

  def priority_color
    priority = @todo.has_priority? ? @todo.priority.downcase.to_sym : :default
    PRIORITY_COLORS[priority]
  end
end