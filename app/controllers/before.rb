# Before all requests
before do

  # Set response type
  content_type :json

end

# Before POST and PUT requests
before :accepted_verbs => ["POST", "PUT"] do

  # Parse JSON
  begin
    @Params = Parser.json(request.body.read)
  rescue Exception => e
    halt 400, output("custom: #{e}")
  end

end

# Before everything other than OPTION requests
before :not_accepted_verbs => ["OPTION"] do

  # Capture URL Params
  @UrlParams = params.dup

  # Items per page
  if @UrlParams.has_key?("size")
    @ItemsPerPage = @UrlParams["size"].to_i == 0 ? App[:listing][:itemsPerPage] : @UrlParams["size"].to_i
    @UrlParams.delete("size")
  else
    @ItemsPerPage = App[:listing][:itemsPerPage]
  end

end

# Before all requests other than the exception
before /(?!\/(exception))/ do

end