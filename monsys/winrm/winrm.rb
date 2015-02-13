#!/usr/bin/env ruby
require 'winrm'

#endpoint = 'http://10.4.0.234:5985/wsman'

if ARGV.length!=3
  puts 'too less params: enpoint, user, pass'
  exit(99)
end

endpoint = ARGV[0]
myuser   = ARGV[1]
mypass	 = ARGV[2]

#$winrm = WinRM::WinRMWebService.new(endpoint, :plaintext, :user => myuser, :pass => mypass, :basic_auth_only => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE)
$winrm = WinRM::WinRMWebService.new(endpoint, :ssl, :user => myuser, :pass => mypass)
#$winrm.cmd('ipconfig /all') do |stdout, stderr|
#  puts stdout
#  puts stderr
#end

def getAllWQL_Obj(wmi_class,object)
  result = $winrm.wql('SELECT * FROM '+wmi_class)
  return result.fetch(object)
end

def getAllWQL(wmi_class)
  result = $winrm.wql('SELECT * FROM '+wmi_class)
  return result
end


def winGetServices
  result = $winrm.wql('select * from Win32_Service').fetch(:win32_service)
#  puts result
  puts 'FOS_RMI_WIN_SERVICES,'+result.length.to_s
#  result.each {|x| puts 'name='+x.fetch(:name)+',status='+x.fetch(:status) }
  result.each {|x| puts 'name='+x.fetch(:name)+
  	                    ',caption='+x.fetch(:caption)+ 
  	                    ',started='+x.fetch(:started)+ 
  	                    ',start_mode='+x.fetch(:start_mode)+ 
  	                    ',state='+x.fetch(:state)
  	                    #',description="'+x.fetch(:description)+'"'
  	          }  
end

def winGetLogicalDisks
  result = $winrm.wql('select * from Win32_LogicalDisk').fetch(:win32_logical_disk)
  puts 'FOS_RMI_WIN_DISKS,'+result.length.to_s  
  result.each {|x| puts 'device_id='+x.fetch(:device_id).to_s+
  		                ',volume_serial_number='+x.fetch(:volume_serial_number).to_s+
  		                ',description='+x.fetch(:description).to_s+
  		                ',file_system='+x.fetch(:file_system).to_s+
  		                ',size='+x.fetch(:size).to_s+
  		                ',free_space='+x.fetch(:free_space).to_s}
end

def winGetSysInfo
  result = getAllWQL('Win32_ComputerSystem').fetch(:win32_computer_system)
  puts 'FOS_RMI_WIN_SYSINFO,'+result.length.to_s  
#  puts result  
  result.each {|x| puts 'name='+x.fetch(:name).to_s+
 					   ',domain='+x.fetch(:domain).to_s+
 				   	   ',total_physical_memory='+x.fetch(:total_physical_memory) 
 		     }
end

def winGetSysOSInfo
  result = getAllWQL('Win32_OperatingSystem').fetch(:win32_operating_system)
  puts 'FOS_RMI_WIN_SYSOS,'+result.length.to_s  
  #puts result
  
 result.each {|x| puts 'caption='+x.fetch(:caption).to_s+
 					   ',csd_version='+x.fetch(:csd_version).to_s+
 					   ',free_physical_memory='+x.fetch(:free_physical_memory).to_s+
 					   ',free_space_in_paging_files='+x.fetch(:free_space_in_paging_files).to_s+
 					   ',free_virtual_memory='+x.fetch(:free_virtual_memory).to_s+
 					   ',last_boot_up_time='+x.fetch(:last_boot_up_time).fetch(:datetime).to_s+
 					   ',serial_number='+x.fetch(:serial_number).to_s+
 					   ',service_pack_major_version='+x.fetch(:service_pack_major_version).to_s+
 					   ',service_pack_minor_version='+x.fetch(:service_pack_minor_version).to_s+
 					   ',total_virtual_memory_size='+x.fetch(:total_virtual_memory_size).to_s+
 					   ',total_visible_memory_size='+x.fetch(:total_visible_memory_size).to_s
 					   #',domain='+x.fetch(:domain).to_s+
 		     }
end
def winGetSoftware
  result = getAllWQL('Win32_Product').fetch(:win32_product)
  puts 'FOS_RMI_WIN_SOFTWARE,'+result.length.to_s  
  result.each {|x| puts 'name='+x.fetch(:name).to_s+
 					   ',version='+x.fetch(:version).to_s
 		     }
end

def winGetIdleProcess
  result = $winrm.wql("SELECT * FROM Win32_PerfFormattedData_PerfProc_Process where name='Idle'").fetch(:win32_perf_formatted_data_perf_proc_process)
  puts 'FOS_RMI_WIN_IDLE_PROCESS,'+result.length.to_s  
  result.each {|x| puts 'name='+x.fetch(:name).to_s+
				',elapsed_time='+x.fetch(:elapsed_time).to_s+
				',creating_process_id='+x.fetch(:creating_process_id).to_s+
				',handle_count='+x.fetch(:handle_count).to_s+
				',id_process='+x.fetch(:id_process).to_s+
				',io_data_bytes_persec='+x.fetch(:io_data_bytes_persec).to_s+
				',io_data_operations_persec='+x.fetch(:io_data_operations_persec).to_s+
				',io_other_bytes_persec='+x.fetch(:io_other_bytes_persec).to_s+
				',io_other_operations_persec='+x.fetch(:io_other_operations_persec).to_s+
				',io_read_bytes_persec='+x.fetch(:io_read_bytes_persec).to_s+
				',io_read_operations_persec='+x.fetch(:io_read_operations_persec).to_s+
				',io_write_bytes_persec='+x.fetch(:io_write_bytes_persec).to_s+
				',io_write_operations_persec='+x.fetch(:io_write_operations_persec).to_s+
				',page_faults_persec='+x.fetch(:page_faults_persec).to_s+
				',page_file_bytes='+x.fetch(:page_file_bytes).to_s+
				',page_file_bytes_peak='+x.fetch(:page_file_bytes_peak).to_s+
				',percent_privileged_time='+x.fetch(:percent_privileged_time).to_s+
				',percent_processor_time='+x.fetch(:percent_processor_time).to_s+
				',percent_user_time='+x.fetch(:percent_user_time).to_s+
				',pool_nonpaged_bytes='+x.fetch(:pool_nonpaged_bytes).to_s+
				',pool_paged_bytes='+x.fetch(:pool_paged_bytes).to_s+
				',priority_base='+x.fetch(:priority_base).to_s+
				',private_bytes='+x.fetch(:private_bytes).to_s+
				',thread_count='+x.fetch(:thread_count).to_s+
				',virtual_bytes='+x.fetch(:virtual_bytes).to_s+
				',virtual_bytes_peak='+x.fetch(:virtual_bytes_peak).to_s+
				',working_set='+x.fetch(:working_set).to_s+
				',working_set_peak='+x.fetch(:working_set_peak).to_s+
				',working_set_private='+x.fetch(:working_set_private).to_s  
 		     }
end

def winGetProcessesList 
  result = getAllWQL('Win32_PerfFormattedData_PerfProc_Process').fetch(:win32_perf_formatted_data_perf_proc_process)
  puts 'FOS_RMI_WIN_ALL_PROCESSES,'+result.length.to_s  
  result.each {|x| puts 'name='+x.fetch(:name).to_s+
				',elapsed_time='+x.fetch(:elapsed_time).to_s+
				',creating_process_id='+x.fetch(:creating_process_id).to_s+
				',handle_count='+x.fetch(:handle_count).to_s+
				',id_process='+x.fetch(:id_process).to_s+
				',io_data_bytes_persec='+x.fetch(:io_data_bytes_persec).to_s+
				',io_data_operations_persec='+x.fetch(:io_data_operations_persec).to_s+
				',io_other_bytes_persec='+x.fetch(:io_other_bytes_persec).to_s+
				',io_other_operations_persec='+x.fetch(:io_other_operations_persec).to_s+
				',io_read_bytes_persec='+x.fetch(:io_read_bytes_persec).to_s+
				',io_read_operations_persec='+x.fetch(:io_read_operations_persec).to_s+
				',io_write_bytes_persec='+x.fetch(:io_write_bytes_persec).to_s+
				',io_write_operations_persec='+x.fetch(:io_write_operations_persec).to_s+
				',page_faults_persec='+x.fetch(:page_faults_persec).to_s+
				',page_file_bytes='+x.fetch(:page_file_bytes).to_s+
				',page_file_bytes_peak='+x.fetch(:page_file_bytes_peak).to_s+
				',percent_privileged_time='+x.fetch(:percent_privileged_time).to_s+
				',percent_processor_time='+x.fetch(:percent_processor_time).to_s+
				',percent_user_time='+x.fetch(:percent_user_time).to_s+
				',pool_nonpaged_bytes='+x.fetch(:pool_nonpaged_bytes).to_s+
				',pool_paged_bytes='+x.fetch(:pool_paged_bytes).to_s+
				',priority_base='+x.fetch(:priority_base).to_s+
				',private_bytes='+x.fetch(:private_bytes).to_s+
				',thread_count='+x.fetch(:thread_count).to_s+
				',virtual_bytes='+x.fetch(:virtual_bytes).to_s+
				',virtual_bytes_peak='+x.fetch(:virtual_bytes_peak).to_s+
				',working_set='+x.fetch(:working_set).to_s+
				',working_set_peak='+x.fetch(:working_set_peak).to_s+
				',working_set_private='+x.fetch(:working_set_private).to_s  
 		     }
end

winGetSysInfo
winGetSysOSInfo
winGetLogicalDisks
winGetServices
#winGetSoftware
winGetIdleProcess
#winGetProcessesList
