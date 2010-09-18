require "prawn/measurement_extensions"
pdf.font "Helvetica", :size => 16

pdf.image "#{RAILS_ROOT}/lib/pdf-base-images/attendance-form.png",
  :at => pdf.bounds.absolute_top_left, :fit => [pdf.bounds.width, pdf.bounds.height]

def write_train_code(pdf, code, at)
  pdf.font("Courier", :size => 23) do
    code.sub("WKS-", "").sub("SES-", "").split("-").each do |segment|
      pdf.text_box segment, :at => at, :height => 0.64.cm, :valign => :bottom, :kerning => false
      at[0] += 2.41.cm
    end
  end
end

write_train_code(pdf, @workshop_session.workshop.train_code, [5.37.cm, pdf.bounds.height - 3.5.cm])
write_train_code(pdf, @workshop_session.train_code, [5.37.cm, pdf.bounds.height - 4.45.cm])

pdf.text_box "#{@workshop_session.workshop.title}: #{@workshop_session.name}",
  :at => [1.0.cm, pdf.bounds.height - 2.45.cm],
  :height => 1.cm, :width => 19.57.cm,
  :align => :center,
  :overflow => :shrink_to_fit

time_str =  @workshop_session.starts_at.strftime("%B %d, %Y") +
  "\n" + @workshop_session.starts_at.strftime("%I:%M %p") + " - " + @workshop_session.ends_at.strftime("%I:%M %p")
pdf.text_box time_str,
  :at => [15.cm, pdf.bounds.height - 3.5.cm],
  :height => 2.cm, :width => 5.02.cm,
  :valign => :center, :align => :right,
  :overflow => :shrink_to_fit,
  :size => 12
