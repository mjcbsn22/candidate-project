# A helper to handle the api response
#
# This helper is used to ensure that the responses are consistent.
#
# Options:
#
#   resource    Data Type: String
#
#               This should be one of the three things below
#
#               Resource Name:
#
#                 It should be in the singular of the word. For example, 'user'
#                 rather than 'users'.
#
#                 In this case the default response message will be used.
#
#               Custom Message:
#
#                 It should be prefixed with the text 'custom:' so that the
#                 helper knows to use it as a vustom message.
#
#               Error:
#
#                 If you are wanting the respone to be an error response you
#                 should send the resource name, just like if you where passing
#                 it normally, prefixed with the text 'error:'.
#
#
#   data        Data Type: Any
#
#               This should be the main body of data that you wish to output. For
#               example all information about a user or a list of all users.

helpers do

  def output(resource, data=nil)

    # Return early if param data types are incorrect
    return "Output Error: Resource must be a string" if !resource.kind_of?(String)
    return "Output Error: Resource must not be blank" if resource.strip == ""

    # Data count
    if data.is_a?(Hash)
      data_count = 1
    else
      data_count = data != nil ? data.count : 0
    end

    # Write messages
    case request.request_method
    when "GET"
      if data_count == 0
        message = "There are no #{resource.downcase.pluralize}"
      elsif data_count == 1
        message = "Showing a single #{resource.downcase}"
      else
        message = "Listing all #{resource.downcase.pluralize}"
      end
    when "POST"
      message = "Created #{resource.downcase}"
    when "PUT"
      message = "Updated #{resource.downcase}"
    when "DELETE"
      message = "Deleted #{resource.downcase}"
    end

    # Setup output
    hash = {}
    content_key = resource

    # Set custom messages
    custom_prefix = "custom:"
    message = resource[custom_prefix.length..-1].lstrip if resource.start_with?(custom_prefix)

    # Set error message
    error_prefix = "error:"
    if resource.start_with?(error_prefix)
      message = "There where errors with this #{resource[error_prefix.length..-1].lstrip}"
      content_key = "errors"
    end

    # Prepare output
    hash = {}
    hash["message"] = message
    hash[content_key.urlize] = data unless data == nil  
    hash["count"] = hash[content_key.urlize].count  if request.request_method == "GET" && data.kind_of?(Array) && data != nil

    # paging
    if @ObjectCountForPaging != nil

      # Get count of all objects
      page = params["page"].to_i
      pages = (@ObjectCountForPaging.to_f / @ItemsPerPage.to_f).ceil

      # Generate page hash
      page_hash = {}
      page_hash[:first] = 1
      page_hash[:previous] = page - 1 unless page <= page_hash[:first]
      page_hash[:current] = page
      page_hash[:next] = page + 1 unless page >= pages
      page_hash[:last] = pages < 1 ? 1 : pages

      # Add page hash to output
      hash["pages"] = page_hash

    end

    # Return output
    JSON.generate hash

  end

end