require "ruboto/widget"
require "priority_dialog_fragment"

require 'vendor/todo'
require 'vendor/colorizer'

java_import 'java.util.ArrayList'

java_import 'android.content.Intent'
java_import "android.util.Log"
java_import 'android.graphics.Color'
java_import 'android.graphics.PorterDuffColorFilter'
java_import 'android.graphics.PorterDuff'
java_import 'android.graphics.Paint'



# read data - ulozi do @todo
# write data - ulozi dle @todo
# draw todos - vykresli @todo (remove a pak kresleni)
# @changed is a flag so we know that something was changed

ruboto_import_widgets :EditText, :TextView, :Button, :LinearLayout, :ListView

class ATodoTxtActivity
  def on_create(bundle)
    super
    @changed = false

    @switch = proc do |todo_text_view|
      todo = @todos[todo_text_view.getId]
      paint_flags = todo_text_view.get_paint_flags

      if todo.done?
        todo.undo
        paint_flags ^= Paint::STRIKE_THRU_TEXT_FLAG
      else
        todo.do
        paint_flags |= Paint::STRIKE_THRU_TEXT_FLAG
      end

      todo_text_view.set_paint_flags(paint_flags)
      todo_text_view.text = todo.text_only
      @changed            = true # TODO - add some UI indicator - e.g. save button
    end

    @choose_priority = proc do |priority_button|
      Log.e "button", priority_button.get_parent.inspect
      x = PriorityDialogFragment.new.show
      Log.e "result", x.inspect
    end

    load_file = proc do |button|
      begin
        intent = Intent.new(Intent::ACTION_GET_CONTENT)
        intent.setType("text/plain")
        intent.addCategory(Intent::CATEGORY_OPENABLE)
        start_activity_for_result(intent, 1)
      rescue # TODO find the exception that is thrown
        button.setText "install file manager!"
      end
    end

    set_content_view(
        linear_layout(:orientation => :vertical) do
          button :text => "Load file...", :on_click_listener => load_file
          @layout = linear_layout(:orientation => :vertical) do

          end
        end
    )

    # TODO remove devel hack
    read_data("/mnt/sdcard/todo.txt")
    draw_todos
  end

  def draw_todos
    @layout.remove_all_views
    @todos.each_with_index do |todo, n|
      @layout.add_view(todo_view(todo,n))
    end
  end

  def todo_view(todo, n)
    linear_layout(:orientation => :horizontal) do
      b = button :text => todo.priority || 'Z', :min_width => 50, :on_click_listener => @choose_priority
      color = Color.parseColor(Colorizer.new(todo).priority_color)
      filter = PorterDuffColorFilter.new(color, PorterDuff::Mode::MULTIPLY)
      b.get_background.set_color_filter(filter)

      text_view(:text              => todo.text_only,
                :padding           => [5, 5, 5, 5],
                :on_click_listener => @switch,
                :id                => n)
    end
  end

  def read_data(file)
    # TODO - add rescues for reading and parsing problem
    @path  = file.to_s.split("://").last
    @todos = Todo.parse(File.read(@path)).sort
  rescue Errno::ENOENT
    handle_error("No such file or directory #{file}")
    @todos = []
  end

  def write_data
    # TODO write @todos to @path
  end

  def handle_error(message)
    Log.e "error occured:", message
  end

  # file was selected
  def on_activity_result(request, result, i)
    super

    if i.respond_to?(:data)
    todo_file = i.data
    Log.d "selected file: ", todo_file.inspect

    read_data(todo_file)
    draw_todos
    else
      handle_error("No data returned")
    end
  end
end

# some examples, to be removed
#@et = edit_text
#linear_layout do
#  button :text => "Hello, World", :on_click_listener => switch
#  button :text => "Hello, Ruboto", :on_click_listener => switch
#end

# tohle fungovalo ale udelalo obyc seznam, nakterej se pristupuje pres adapter
#@todos = list_view(:list => ['a', 'b', 'c'])
#@adapter = @todos.get_adapter #.get_wrapped_adapter
#    @adapter.clear
#    #@todos.remove_all_views # todle pada, takhle to nefunguje, najit spravnou metodu
#    #@todos.remove_header_view @header if @header
#    #@header = text_view(:text => @path || '')
#    #@todos.add_header_view @header
#    todos.each_with_index do |todo, n|
#      @adapter.add todo.to_s
#      #text_view(:text              => todo.to_s,
#      #                       :padding           => [5, 5, 5, 5],
#      #                       :on_click_listener => @switch,
#      #                       :id                => n
#      #             )
#    end
