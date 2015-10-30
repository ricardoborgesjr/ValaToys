public class Application : Gtk.Window{
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
        this.title = "Trending Topic Places";
        this.window_position = Gtk.WindowPosition.CENTER;
        this.destroy.connect(Gtk.main_quit);
        this.set_default_size(350, 70);
        
        //The Entry
        Gtk.Entry entry = new Gtk.Entry();
        this.add(entry);
        
        //The EntryCompletion
        Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();
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
    }
    
    public static int main (string[] args) {
        Gtk.init (ref args);

        Application app = new Application ();
        app.show_all ();
        Gtk.main ();
        return 0;
    }
}
