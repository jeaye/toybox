%include "data.inc"

%ifndef data_extern_inc
  %define data_extern_inc

  %if LOGGING
    %if DEBUG
      extern str_debug_log_prefix
      def_extern_str server_starting
      def_extern_str created_socket
      def_extern_str bound_socket
      def_extern_str listening
      def_extern_str accepted
      def_extern_str bad_request
    %endif

    def_extern_str error_log_prefix
    def_extern_str failed_to_create_socket
    def_extern_str failed_to_bind_socket
    def_extern_str failed_to_bind_signal_handler
    def_extern_str failed_to_listen
    def_extern_str failed_to_accept
    def_extern_str failed_to_receive_data
    def_extern_str failed_to_allocate_memory
  %endif

  def_extern_str empty
  def_extern_str cr_lf_cr_lf
  def_extern_str base_chars

  def_extern_str http_method_get
  def_extern_str http_version
  def_extern_str http_ignored
  def_extern_str http_content_length
  def_extern_str http_index_html
  def_extern_str http_200

  def_extern_str working_dir
  extern local_address
  extern remote_address
  extern request_buffer
  extern len_request_buffer
  extern request_context
  extern file_stat
  extern signal_action

%endif
