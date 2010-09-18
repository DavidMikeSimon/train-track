require "prawn/measurement_extensions"

pdf.image "#{RAILS_ROOT}/lib/pdf-base-images/attendance-form.png", :at => pdf.bounds.absolute_top_left, :fit => [pdf.bounds.width, pdf.bounds.height]

def write_train_code(pdf, code, at)
  pdf.font "Courier", :size => 23
  code.sub("WKS-", "").sub("SES-", "").split("-").each do |segment|
    pdf.text_box segment, :at => at, :height => 0.64.cm, :valign => :bottom, :kerning => false
    at[0] += 2.41.cm
  end
end

write_train_code(pdf, @workshop_session.workshop.train_code, [5.37.cm, pdf.bounds.height - 3.5.cm])
write_train_code(pdf, @workshop_session.train_code, [5.37.cm, pdf.bounds.height - 4.45.cm])
