include XlsxToCsv
class UploadController < ApplicationController
  skip_before_filter:verify_authenticity_token, only: [:new]
  def new
    file = params[:attachment]
    unless file.nil?
      name = file.original_filename
      perms = ['.xlsx']
      if !perms.include?(File.extname(name).downcase)
        result = 'アップロードできるのはエクセル(.xlsx形式)ファイルのみです。'
      else
        file_dir = 'tmp/menu/'
        File.open(file_dir + name, 'wb') { |f| f.write(file.read) }
        result = "#{name}をアップロードしました。"
        converter = XlsxToCsv
        begin
          converter.convertXlsx file_dir + name
        rescue
          result = 'ファイル名はYYYYMMDD-YYYYMMDD.xlsxの形式にしてください。例: 20140501-20140507.xlsx'
        else
          converter.createModels
        ensure
          File.unlink (file_dir + name)
        end
      end
      redirect_to("/admin/upload_new_file", :alert => result)
    else
      render text: '406 Not Acceptable', status: 406
    end
  end
end
