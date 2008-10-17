module ActionController
  module PolymorphicRoutes
    def polymorphic_url(record_or_hash_or_array, options = {})
      if record_or_hash_or_array.kind_of?(Array)
        record_or_hash_or_array = record_or_hash_or_array.dup
      end

      record    = extract_record(record_or_hash_or_array)
      format    = extract_format(record_or_hash_or_array, options)
      namespace = extract_namespace(record_or_hash_or_array)

      args = case record_or_hash_or_array
        when Hash;  [ record_or_hash_or_array ]
        when Array; record_or_hash_or_array.dup
        else        [ record_or_hash_or_array ]
      end

      inflection =
        case
        when options[:action].to_s == "new"
          args.pop
          :singular
        when record.respond_to?(:new_record?) && record.new_record?
          args.pop
          :plural
        else
          :singular
        end

      args = handle_has_one_nested(args)

      args.delete_if {|arg| arg.is_a?(Symbol) || arg.is_a?(String)}
      args << format if format

      named_route = build_named_route_call(record_or_hash_or_array, namespace, inflection, options)

      url_options = options.except(:action, :routing_type, :format, :association)
      unless url_options.empty?
        args.last.kind_of?(Hash) ? args.last.merge!(url_options) : args << url_options
      end

      __send__(named_route, *args)
    end

    def handle_has_one_nested(args)
      if args.size == 2
        model_class = args.first.class # Constituency
        if model_class.respond_to?(:reflect_on_association)
          second_model_class = args.last.class # Member
          association_name = second_model_class.name.tableize.singularize.to_sym # :member
          association = model_class.reflect_on_association(association_name)  # Constituency.reflect_on_association(:member)
          if association && association.macro == :has_one
            args.pop
          end
        end
      end
      args
    end
  end
end
