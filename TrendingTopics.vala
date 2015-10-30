using Gtk;
public class Application{
    public Json.Array get_places () {
        var uri = "http://localhost/places.json";

        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", uri);
        session.send_message (message);
        var root_object = new Json.Array();
        try {
            var parser = new Json.Parser ();
            parser.load_from_data ((string) message.response_body.flatten ().data, -1);

            root_object = parser.get_root ().get_array ();
            
        } catch (Error e) {
            stderr.printf ("I guess something is not working...\n");
        }
        
        return root_object;
    }
    
    public Application (){
        // If the UI contains custom widgets, their types must've been instantiated once
        // Type type = typeof(Foo.BarEntry);
        // assert(type != 0);
        var builder = new Builder ();
        builder.add_from_file ("window.ui");
        builder.connect_signals (null);
        var window = builder.get_object ("window") as Window;
            
        
        //The Entry
        var entry = builder.get_object ("entry") as Entry;
        
        
        //The EntryCompletion
        EntryCompletion completion = new EntryCompletion ();
        entry.set_completion(completion);
        
        Gtk.ListStore list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        completion.set_model(list_store);
        completion.set_text_column(0);
        var cell = new Gtk.CellRendererText();
        completion.pack_start(cell, false);
        completion.add_attribute(cell, "text", 1);
        
        Gtk.TreeIter iter;
        
        var places = get_places();
        
        foreach (var placenode in places.get_elements()) {
            var place = placenode.get_object();
            
            list_store.append(out iter);
            list_store.set(iter, 0, place.get_string_member("name"), 1, place.get_string_member("country"));
        }
        
        window.show_all ();
        
    }
    
    public static int main (string[] args) {
        Gtk.init (ref args);

        try {
            Application app = new Application ();
            Gtk.main ();
        } catch (Error e) {
            stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    }
        return 0;
    }
}
