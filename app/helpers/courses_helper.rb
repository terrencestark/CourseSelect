module CoursesHelper
    def get_week_bool_matrix(str_time)     #将课程的上课周数替换成数组
      arr=Array.new
      reg = /((\d\d?)-(\d\d?))(.(\d\d?)-(\d\d?))?/
      md = reg.match(str_time)
      for i in md[2].to_i..md[3].to_i
      arr[i]=i
      end
      if md[4]!=nil
        for i in md[5].to_i..md[6].to_i
        arr[i]=i
        end
      end
      arr
    end
    
    def if_has_same_week(week_bool_matrix1,week_bool_matrix2) #判断两个课程是否有重叠的周数
      for i in 1..22
        if week_bool_matrix1[i]==week_bool_matrix2[i]&&week_bool_matrix1[i]!=nil
          return true
        end
      end
    end
    
    def if_has_same_time(time_bool_matrix1,time_bool_matrix2) #判断两个课程是否有重叠的上课时间
      for i in 1..7
        for j in 1..11
          if time_bool_matrix1[i][j]==time_bool_matrix2[i][j]&&time_bool_matrix1[i][j]==true
            return true
          end
        end
      end
    end
    # index 0 not use!
    def get_time_bool_matrix(str_time)
      reg = /(周)(一|二|三|四|五|六|日)\((\d\d?)-(\d\d?)/
      md = reg.match(str_time)
      if md==nil
        return nil
      else
        week_num_str = md[2]
        week_num = get_week_num(week_num_str)
        if week_num==nil
          return nil
        end
        class_start_num = md[3].to_i
        class_end_num = md[4].to_i
        arr = Array.new(1+11, 0) # 11 classes per day 1 to 11, 0 not use
        arr.collect! do |e|
          e = Array.new(1+7, false)# 1 to 7 day, 0 not use
        end
        i = class_start_num
        while i<=class_end_num
          arr[i][week_num] = true
          i+=1
        end
        arr
      end
    end
    
    def get_course_time_para_hash(str_time)
      ret = {week_value: 0, class_start: 0, class_end: 0}
      reg = /(周)(一|二|三|四|五|六|日)\((\d\d?)-(\d\d?)/
      md = reg.match(str_time)
      if md==nil
        return nil
      else
        week_num_str = md[2]
        ret[:week_value] = get_week_num(week_num_str)
        ret[:class_start] = md[3].to_i
        ret[:class_end] = md[4].to_i
      end
      ret
    end
    
    def get_week_num(week_num_str)
      case week_num_str
        when /一/
          week_num = 1
        when /二/
          week_num = 2
        when /三/
          week_num = 3
        when /四/
          week_num = 4
        when /五/
          week_num = 5
        when /六/
          week_num = 6
        when /日/
          week_num = 7
        else
          return nil
      end
      return week_num
    end
    
    def merge_course_to_hash_matrix(matrix, course_hash)
      # example h1{course_name: "math", course_time: "周四(7-8)"}
      if matrix==nil
        matrix = Array.new(1+11, 0)
        matrix.collect! do |e|
          e = Array.new(1+7, 0)# 1 to 7 day, 0 not use
          e.collect! do |k|
              k = Array.new()
          end
        end
      end
      if course_hash.has_key?(:course_name) && course_hash.has_key?(:course_time)
        para = get_course_time_para_hash(course_hash[:course_time])
        puts para
        if para!=nil
          i = para[:class_start]
          puts "gogo"
          while i<= para[:class_end]
            arr = matrix[i]
            subarr = arr[para[:week_value]]
            subarr.push(course_hash[:course_name])
            i+=1
          end
        end
      end
      matrix
    end
end