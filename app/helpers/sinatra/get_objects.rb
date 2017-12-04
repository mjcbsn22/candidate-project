# A helper to get objects

helpers do

  def get_objects(object, options={})

    # Setup
    isParams, notParams = @UrlParams, {}
    @ObjectCountForPaging = nil

    # Get not url params
    isParams.each do |key, value|
      if key.start_with?("!")
        objectKey = key.dup[1...key.length]
        notParams[objectKey] = value
        isParams.delete(key)
      end
    end

    # Merge code params and user url params
    isParams = isParams.merge(options[:params]) if options.has_key?(:params)

    # If page is specified
    if isParams.has_key?("page")
      page = isParams["page"].to_i
      isParams.delete("page")
    end

    # Select
    selectArray = nil
    if options.has_key?(:select)
      selectArray = options[:select].reject{|x| !object.new.attributes.keys.member?(x.to_s) } if options[:select].is_a?(Array)
    end

    # Sort
    if isParams.has_key?("sort")
      match = /([a-z_]+):(DESC|ASC)/.match(isParams["sort"])
      match = object.new.attributes.keys.member?(match[1]) ? match : nil if match != nil
      isParams.delete("sort")
    end

    notParams = notParams.reject{|k,v| !object.new.attributes.keys.member?(k.to_s)} if notParams.keys.count > 0
    isParams = isParams.reject{|k,v| !object.new.attributes.keys.member?(k.to_s)}

    # Transform options
    # Transform Null to Nil
    isParams.each{|k,v| isParams[k] = v == "null" ? nil : v}
    notParams.each{|k,v| notParams[k] = v == "null" ? nil : v}
    # Transform Bools to Bools
    isParams.each{|k,v| isParams[k] = v != nil && v.to_b != nil ? v.to_b : v if object.columns_hash[k].type == :boolean}
    notParams.each{|k,v| notParams[k] = v != nil && v.to_b != nil ? v.to_b : v if object.columns_hash[k].type == :boolean}

    # Merge where options and url params
    isParams = isParams.merge(Hash[options[:where].map{|k,v| [k.to_s, v]}]) if options.has_key?(:where)

    # Query DB
    objects = object
    notParams.each do |field,query|
      objects = object.where("#{field} NOT ILIKE ?", "%#{query}%")
    end
    isParams.each do |field,query|
      objects = object.where("#{field} ILIKE ?", "%#{query}%")
    end
    objects = object.where(options[:sql]) if options.has_key?(:sql)
    @ObjectCountForPaging = objects.count if page != nil
    objects = object.select(selectArray) if selectArray != nil
    objects = objects.limit(@ItemsPerPage).offset(@ItemsPerPage * (page - 1)) if page != nil
    objects = objects.order("#{match[1]} #{match[2]}") if match != nil

    # Return
    return objects

  end

end