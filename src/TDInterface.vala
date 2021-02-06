/* TDInterface.vala
 *
 * Copyright 2020 MrSyabro
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

 namespace TDInterface
 {

 	delegate bool? CallbackType (Json.Node data);

 	class Request : Object
 	{

		public string? response_type { get; set; }
		public Json.Node? request_data { get; set; }
		public CallbackType? callback { get; set;}
		public bool online { get; set; default = false; }
		// TODO: public int? timeout { get; set; }

		public Request (string? response_type, Json.Node? request, CallbackType? callback, bool online)
		{

			this.response_type = response_type;
			this.request_data = request;
			if (this.response_type != null)
				this.callback = callback;
			this.online = online;

		}

 	}

 	class Client : Object
 	{

 		public void* client { get; set; }
        public bool loop_stop { get; set; default = false; }
        public int client_uid { get; set; }
        public bool pending_requests { get; set; }
        public Thread<void> client_thread;
        public Gee.ArrayList<Request> request_queue;
		public uint offline_count { get; set; default = 0; }
		public MainLoop mainloop { get; set; }

		public void thread_func()
		{

			var timer = new Timer ();
        	timer.start ();

        	const double TIMEOUT = 1.0;

        	while(!loop_stop)
	        {

	            string response = Td_json.client_receive(client, TIMEOUT);

	            if (response != null && response != "(null)")
	            {

					//debug(response);
					receive_message_idle_func(response);

	            }

	            Thread.usleep(100);

	        }

			return;

		}

		void receive_message_idle_func (string data)
        {

            GLib.Idle.add (() => {

				var root_node = Json.from_string(data);
				var root_obj = root_node.get_object();
				string response_type = root_obj.get_string_member("@type");

                for (int i = 0; i < request_queue.size; i++)
                {

                	var request = request_queue.@get(i);

					//debug ("Received [%s] == [%s]", response_type, request.response_type);

					if (response_type == request.response_type)
					{

						bool del = request.callback(root_node);
						if (!request.online)
						{

							assert(request_queue.remove(request));
							offline_count--;
							i--;

							requests_pending (offline_count > 0);

						}
						else if (del == true)
						{

							assert(request_queue.remove(request));

						}

					}

                }

                //debug ("Requests in queue %s", request_queue.size.to_string());

                return false;
            });

        }

        public signal void requests_pending (bool stats);

 	}

    class Interface : Client
    {

        // Ключ шифрования кеша базы данных. Временная мера.
        // TODO: Добавить генерацию и хранение ключа в хранилище Gnome
        public string key { get; set; default = ""; }

		public Interface(int client_uid)
		{

			this.request_queue = new Gee.ArrayList<Request> ();

			this.client_uid = client_uid;
			this.client = Td_json.client_create();

		}

        public void run()
        {

        	this.client_thread = new Thread<void> (string.join("_","TDLib_thread", this.client_uid.to_string()), this.thread_func);

			this.mainloop = new MainLoop();
			this.mainloop.run();

        }

        public void stop()
        {

			this.loop_stop = true;

			this.client_thread.join();
			this.mainloop.quit();

            Td_json.client_destroy(this.client);

        }

    }
}
