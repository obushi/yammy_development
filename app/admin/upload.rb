include XlsxToCsv

ActiveAdmin.register_page "Upload New File" do
  content :title => "献立ファイルをアップロード" do
    converter = XlsxToCsv
    form action:"/upload", method:"post", enctype:"multipart/form-data", id:"uploadForm" do
        input name:"attachment", type:"file"
        input type:"submit", id:"uploadButton"
    end
  end
end