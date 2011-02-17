require "prawn/measurement_extensions"
pdf.font "Helvetica", :size => 16

def draw_label(pdf, idx, appointment)
  col = idx / 10
  row = idx % 10
  pos = [(0.71 + 6.99*col).cm, pdf.bounds.height - (1.55 + 2.54*row).cm]
  width = 6.17.cm
  height = 2.01.cm

  rows = [
    [2, lambda {|a| a.train_code}, {:font => "Courier-Bold"}],
    [0.5, lambda {|a| ""}],
    [4, lambda {|a| "#{a.person.first_name} #{a.person.last_name}"}],
    [2.5, lambda {|a| (a.person.institution.try.medium_name).to_s}],
    [2, lambda {|a| [(a.person.job ? a.person.job.name : nil), (a.person.job_details == "" ? nil : a.person.job_details)].reject(&:nil?).join(" - ")}],
    [0.5, lambda {|a| ""}],
    [2, lambda {|a| a.train_code}, {:font => "Courier-Bold", :rotate => 180, :rotate_around => :center}]
  ]

  proportion_total = rows.sum{|r| r[0]}
  rows.each do |row|
    proportion = row[0]
    text = row[1].call(appointment)
    opts = row[2] || {}
    row_height = (proportion.to_f/proportion_total)*height
    pdf.font(opts.has_key?(:font) ? opts.delete(:font) : "Helvetica") do
      pdf.text_box text, {
        :at => pos,
        :height => row_height*0.9,
        :width => width,
        :align => :center,
        :overflow => :shrink_to_fit,
        :min_font_size => 7
      }.merge(opts)
    end
    pos[1] -= row_height
  end
end

i = 0
@workshop.appointments.all(:conditions => {:print_needed => true}, :include => {:person => :institution}, :order => "people.last_name, people.first_name").each do |appt|
  if i == 30
    i = 0
    pdf.start_new_page
  end
  draw_label(pdf, i, appt)
  i += 1
end
