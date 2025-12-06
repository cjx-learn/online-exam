package com.exam.service;

import com.exam.entity.Course;
import com.exam.entity.Student;
import com.exam.entity.Teacher;
import com.exam.mapper.CourseMapper;
import com.exam.mapper.StudentMapper;
import com.exam.mapper.TeacherMapper;
import com.exam.util.PasswordUtil;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Excel导入服务
 */
@Service
public class ExcelImportService {

    @Autowired
    private CourseMapper courseMapper;

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private TeacherMapper teacherMapper;

    /**
     * 批量导入课程
     * Excel格式: 课程代码(必填) | 课程名称(必填) | 分类 | 学分 | 学时 | 院系 | 描述
     */
    @Transactional
    public Map<String, Object> importCourses(MultipartFile file) throws Exception {
        List<Course> courses = new ArrayList<>();
        List<String> errors = new ArrayList<>();
        int successCount = 0;

        try (InputStream is = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {
            
            Sheet sheet = workbook.getSheetAt(0);
            int rowCount = sheet.getPhysicalNumberOfRows();

            // 从第2行开始读取（第1行是表头）
            for (int i = 1; i < rowCount; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    Course course = new Course();
                    course.setCode(getCellStringValue(row.getCell(0)));
                    course.setName(getCellStringValue(row.getCell(1)));
                    course.setCategory(getCellStringValue(row.getCell(2)));
                    course.setCredit(getCellBigDecimalValue(row.getCell(3)));
                    course.setHours(getCellIntValue(row.getCell(4)));
                    course.setDepartment(getCellStringValue(row.getCell(5)));
                    course.setDescription(getCellStringValue(row.getCell(6)));
                    course.setLevel("Undergraduate");
                    course.setStatus(1);

                    // 验证必填字段
                    if (course.getCode() == null || course.getCode().isEmpty()) {
                        errors.add("第" + (i + 1) + "行: 课程代码不能为空");
                        continue;
                    }
                    if (course.getName() == null || course.getName().isEmpty()) {
                        errors.add("第" + (i + 1) + "行: 课程名称不能为空");
                        continue;
                    }

                    // 检查是否已存在
                    if (courseMapper.selectByCode(course.getCode()) != null) {
                        errors.add("第" + (i + 1) + "行: 课程代码 " + course.getCode() + " 已存在");
                        continue;
                    }

                    courseMapper.insert(course);
                    successCount++;
                } catch (Exception e) {
                    errors.add("第" + (i + 1) + "行: " + e.getMessage());
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("successCount", successCount);
        result.put("errorCount", errors.size());
        result.put("errors", errors);
        return result;
    }

    /**
     * 批量导入学生
     * Excel格式: 用户名(必填) | 真实姓名 | 学号 | 邮箱 | 手机号
     */
    @Transactional
    public Map<String, Object> importStudents(MultipartFile file) throws Exception {
        List<String> errors = new ArrayList<>();
        int successCount = 0;
        String defaultPassword = PasswordUtil.encode("123456");

        try (InputStream is = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {
            
            Sheet sheet = workbook.getSheetAt(0);
            int rowCount = sheet.getPhysicalNumberOfRows();

            for (int i = 1; i < rowCount; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    Student student = new Student();
                    student.setUsername(getCellStringValue(row.getCell(0)));
                    student.setRealName(getCellStringValue(row.getCell(1)));
                    student.setStudentNo(getCellStringValue(row.getCell(2)));
                    student.setEmail(getCellStringValue(row.getCell(3)));
                    student.setPhone(getCellStringValue(row.getCell(4)));
                    student.setPassword(defaultPassword);
                    student.setStatus(1);

                    // 验证必填字段（仅username是数据库NOT NULL）
                    if (student.getUsername() == null || student.getUsername().isEmpty()) {
                        errors.add("第" + (i + 1) + "行: 用户名不能为空");
                        continue;
                    }

                    // 检查用户名是否已存在
                    if (studentMapper.selectByUsername(student.getUsername()) != null) {
                        errors.add("第" + (i + 1) + "行: 用户名 " + student.getUsername() + " 已存在");
                        continue;
                    }

                    studentMapper.insert(student);
                    successCount++;
                } catch (Exception e) {
                    errors.add("第" + (i + 1) + "行: " + e.getMessage());
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("successCount", successCount);
        result.put("errorCount", errors.size());
        result.put("errors", errors);
        return result;
    }

    /**
     * 批量导入教师
     * Excel格式: 用户名(必填) | 真实姓名 | 工号 | 邮箱 | 手机号 | 院系 | 职称
     */
    @Transactional
    public Map<String, Object> importTeachers(MultipartFile file) throws Exception {
        List<String> errors = new ArrayList<>();
        int successCount = 0;
        String defaultPassword = PasswordUtil.encode("123456");

        try (InputStream is = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {
            
            Sheet sheet = workbook.getSheetAt(0);
            int rowCount = sheet.getPhysicalNumberOfRows();

            for (int i = 1; i < rowCount; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    Teacher teacher = new Teacher();
                    teacher.setUsername(getCellStringValue(row.getCell(0)));
                    teacher.setRealName(getCellStringValue(row.getCell(1)));
                    teacher.setTeacherNo(getCellStringValue(row.getCell(2)));
                    teacher.setEmail(getCellStringValue(row.getCell(3)));
                    teacher.setPhone(getCellStringValue(row.getCell(4)));
                    teacher.setDepartment(getCellStringValue(row.getCell(5)));
                    teacher.setTitle(getCellStringValue(row.getCell(6)));
                    teacher.setPassword(defaultPassword);
                    teacher.setStatus(1);

                    // 验证必填字段（仅username是数据库NOT NULL）
                    if (teacher.getUsername() == null || teacher.getUsername().isEmpty()) {
                        errors.add("第" + (i + 1) + "行: 用户名不能为空");
                        continue;
                    }

                    // 检查用户名是否已存在
                    if (teacherMapper.selectByUsername(teacher.getUsername()) != null) {
                        errors.add("第" + (i + 1) + "行: 用户名 " + teacher.getUsername() + " 已存在");
                        continue;
                    }

                    teacherMapper.insert(teacher);
                    successCount++;
                } catch (Exception e) {
                    errors.add("第" + (i + 1) + "行: " + e.getMessage());
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("successCount", successCount);
        result.put("errorCount", errors.size());
        result.put("errors", errors);
        return result;
    }

    // 工具方法：获取单元格字符串值
    private String getCellStringValue(Cell cell) {
        if (cell == null) return null;
        String value;
        switch (cell.getCellType()) {
            case STRING:
                value = cell.getStringCellValue();
                break;
            case NUMERIC:
                // 处理数字类型，避免科学计数法
                double numValue = cell.getNumericCellValue();
                if (numValue == Math.floor(numValue)) {
                    value = String.valueOf((long) numValue);
                } else {
                    value = String.valueOf(numValue);
                }
                break;
            case BOOLEAN:
                value = String.valueOf(cell.getBooleanCellValue());
                break;
            default:
                value = null;
        }
        return value != null ? value.trim() : null;
    }

    // 工具方法：获取单元格整数值
    private Integer getCellIntValue(Cell cell) {
        if (cell == null) return null;
        if (cell.getCellType() == CellType.NUMERIC) {
            return (int) cell.getNumericCellValue();
        }
        try {
            return Integer.parseInt(cell.getStringCellValue().trim());
        } catch (Exception e) {
            return null;
        }
    }

    // 工具方法：获取单元格BigDecimal值
    private BigDecimal getCellBigDecimalValue(Cell cell) {
        if (cell == null) return null;
        if (cell.getCellType() == CellType.NUMERIC) {
            return BigDecimal.valueOf(cell.getNumericCellValue());
        }
        try {
            return new BigDecimal(cell.getStringCellValue().trim());
        } catch (Exception e) {
            return null;
        }
    }
}
