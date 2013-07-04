java_import 'android.app.AlertDialog'
java_import 'android.support.v4.app.DialogFragment' # ani todle nejde :-/

class PriorityDialogFragment < DialogFragment
  def onCreateDialog(bundle)
    builder = AlertDialog::Builder.new self.activity
    builder.set_message("Choose priority").set_title("Choose priority")
    builder.create
  end
end