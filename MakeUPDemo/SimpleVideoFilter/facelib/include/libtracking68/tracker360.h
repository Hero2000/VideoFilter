//
//  tracker360.h
//  libtracking68
//
//  Created by tangyu on 16/3/22.
//  Copyright © 2016年 tangyu. All rights reserved.
//

#ifndef tracker360_h
#define tracker360_h


#ifdef _MSC_VER
#ifdef __cplusplus
#ifdef SDK_EXPORTS
#define TRACKER360_SDK_API  extern "C" __declspec(dllexport)
#else
#define TRACKER360_SDK_API extern "C" __declspec(dllimport)
#endif
#else
#ifdef SDK_EXPORTS
#define TRACKER360_SDK_API __declspec(dllexport)
#else
#define TRACKER360_SDK_API __declspec(dllimport)
#endif
#endif
#else /* _MSC_VER */
#ifdef __cplusplus
#ifdef SDK_EXPORTS
#define TRACKER360_SDK_API  extern "C" __attribute__((visibility ("default")))
#else
#define TRACKER360_SDK_API extern "C"
#endif
#else
#ifdef SDK_EXPORTS
#define TRACKER360_SDK_API __attribute__((visibility ("default")))
#else
#define TRACKER360_SDK_API
#endif
#endif
#endif

/// qh handle declearation
typedef void *qh_handle_t;

/// qh result declearation
typedef int   qh_result_t;

#define QH_OK (0)               ///< 正常运行
#define QH_E_INVALIDARG (-1)	///< 无效参数
#define QH_E_HANDLE (-2)        ///< 句柄错误
#define QH_E_OUTOFMEMORY (-3)	///< 内存不足
#define QH_E_FAIL (-4)          ///< 内部错误
#define QH_E_DELNOTFOUND (-5)	///< 定义缺失

/// qh rectangle definition
typedef struct qh_rect_t {
    int left;	///< 矩形最左边的坐标
    int top;	///< 矩形最上边的坐标
    int right;	///< 矩形最右边的坐标
    int bottom;	///< 矩形最下边的坐标
} qh_rect_t;

/// qh float type point definition
typedef struct qh_pointf_t {
    float x;	///< 点的水平方向坐标，为浮点数
    float y;	///< 点的竖直方向坐标，为浮点数
} qh_pointf_t;

/// qh integer type point definition
typedef struct qh_pointi_t {
    int x;		///< 点的水平方向坐标，为整数
    int y;		///< 点的竖直方向坐标，为整数
} qh_pointi_t;

/// qh pixel format definition
typedef enum {
    QH_PIX_FMT_NV21,        ///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 )
    QH_PIX_FMT_BGRA8888,	///< BGRA 8:8:8:8 32bpp ( 4通道32bit BGRA 像素 )
}qh_pixel_format;

/// @brief  人脸朝向
typedef enum {
    QH_FACE_UP = 0,		///< 人脸向上，即人脸朝向正常
    QH_FACE_LEFT = 1,	///< 人脸向左，即人脸被逆时针旋转了90度
    QH_FACE_DOWN = 2,	///< 人脸向下，即人脸被逆时针旋转了180度
    QH_FACE_RIGHT = 3	///< 人脸向右，即人脸被逆时针旋转了270度
} qh_face_orientation;

/// @brief 人脸信息结构体
typedef struct qh_face_t {
    qh_rect_t rect;                 ///< 代表面部的矩形区域
    float score;                    ///< 置信度，用于筛除负例，与人脸照片质量无关，值越高表示置信度越高。
    qh_pointf_t points5[5];         ///< 人脸5关键点的数组
    qh_pointf_t points_fine[95];	///< 人脸95关键点的数组
    int points_count;               ///< 人脸95关键点数组的长度，如果没有计算关键点，则为0
    int ID;                         ///< faceID，用于表示在实时人脸跟踪中的相同人脸在不同帧多次出现，在人脸检测的结果中无实际意义
} qh_face_t;

/// @brief 创建实时人脸跟踪句柄
/// @param model_path 模型文件的绝对路径或相对路径，若不指定模型可为NULL
/// @param config 配置选项，推荐使用 CV_FACE_SKIP_BELOW_THRESHOLD | CV_TRACK_MULTI_TRACKING
/// @return 成功返回人脸跟踪句柄，失败返回NULL
TRACKER360_SDK_API
qh_handle_t
qh_face_create_tracker(
                       const char *model_path
                       );

/// @brief 销毁已初始化的实时人脸跟踪句柄
/// @param tracker_handle 已初始化的实时人脸跟踪句柄
TRACKER360_SDK_API
void
qh_face_destroy_tracker(
                        qh_handle_t tracker_handle
                        );

/// @brief 对连续视频帧进行实时快速人脸跟踪
/// @param tracker_handle 已初始化的实时人脸跟踪句柄
/// @param image 用于检测的图像数据
/// @param piexl_format 用于检测的图像数据的像素格式
/// @param image_width 用于检测的图像的宽度(以像素为单位)
/// @param image_height 用于检测的图像的高度(以像素为单位)
/// @param image_stride 用于检测的图像中每一行的跨度(以像素为单位)
/// @param orientation 视频中人脸的方向
/// @param p_faces_array 检测到的人脸信息数组，api负责分配内存，需要调用cv_facesdk_release_tracker_result函数释放
/// @param p_faces_count 检测到的人脸数量
/// @return 成功返回CV_OK，否则返回错误类型
TRACKER360_SDK_API
qh_result_t
qh_face_track(
              qh_handle_t tracker_handle,
              const unsigned char *image,
              qh_pixel_format pixel_format,
              int image_width,
              int image_height,
              int image_stride,
              qh_face_orientation orientation,
              qh_face_t **p_faces_array,
              int *p_faces_count,
              bool bDetect95
              );

/// @brief 对连续视频帧进行实时快速人脸跟踪
/// @param px 返回人脸中心点x坐标，多张人脸取最大脸
/// @param py 返回人脸中心点y坐标，多张人脸取最大脸
/// @return 成功返回CV_OK，否则返回错误类型
TRACKER360_SDK_API
qh_result_t
qh_face_detect_point(
                     qh_handle_t tracker_handle,
                     const unsigned char *image,
                     qh_pixel_format pixel_format,
                     int image_width,
                     int image_height,
                     int image_stride,
                     qh_face_orientation orientation,
                     int *px,
                     int *py
                     );

/// @brief 释放实时人脸跟踪返回结果时分配的空间
/// @param faces_array 检测到的人脸信息数组
/// @param faces_count 检测到的人脸数量
TRACKER360_SDK_API
void
qh_face_release_tracker_result(
                               qh_face_t *faces_array,
                               int faces_count
                               );

#endif /* tracker360_h */
