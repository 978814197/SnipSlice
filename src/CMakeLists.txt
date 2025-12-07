# 添加可执行程序目标，包含主程序入口
qt_add_executable(${CMAKE_PROJECT_NAME}
        main.cpp
        ImageProcessor.h
        ImageProcessor.cpp
)

# 添加UI插件子目录
add_subdirectory(ui)

# 链接插件库
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
        uiplugin
)

# 定义翻译目标语言
set(TRANSLATION_TARGET zh_CN en_US)

# 生成翻译文件路径
set(TS_FILES "")
foreach (lang ${TRANSLATION_TARGET})
    list(APPEND TS_FILES "${CMAKE_SOURCE_DIR}/translations/${PROJECT_NAME}_${lang}.ts")
endforeach ()

# 将翻译文件添加到可执行程序中
qt_add_translations(${CMAKE_PROJECT_NAME}
        TS_FILES ${TS_FILES}
        RESOURCE_PREFIX /i18n
)