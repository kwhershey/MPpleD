#ifndef CURLWRAPPER_H_
#define CURLWRAPPER_H_

#include <qobject.h>
#include <qstring.h>
#include <qfile.h>
#include <qcstring.h>
#include <qtimer.h>

#include <curl/curl.h>

class CurlWrapper : public QObject
{
	Q_OBJECT

	public:
		CurlWrapper(QObject *parent = 0, const char *name = 0);
		~CurlWrapper();

		void getData(const QString &url);
		void download(const QString &url, const QString &filename);
		void cancel();

		const QString url() const;
		const QByteArray data() const;
		bool isRunning() const;

		// Call from your program's main function
		// to initialize/clean up the curl library.
		static void init();
		static void cleanup();

	private:
		QTimer *timer;
		bool downloadToMemory;
		bool wasCanceled;

		CURLM *dl_multi;
		CURL *dl_handle;
		struct curl_slist *dl_headers;
		char dl_error[CURL_ERROR_SIZE];

		QFile *outputFile;
		QByteArray dlData;

		QString pUrl;
		int running_handles;

		void startDownload(const QString &url);
		size_t storeData(void *ptr, size_t size, size_t nmemb);
		size_t writeData(void *ptr, size_t size, size_t nmemb);
		void setProgress(int done, int total);

		static size_t writeCallback(void *ptr,
					size_t size, size_t nmemb,
					void *userdata);
		static int progressCallback(void *clientp,
					double dltotal, double dlnow,
					double ultotal, double ulnow);

	private slots:
		void downloadLoop();

	signals:
		void error(const QString &message);
		void progress(int done, int total);
		void status(const QString &message);

		void finished();
};

#endif  // CURLWRAPPER_H_
