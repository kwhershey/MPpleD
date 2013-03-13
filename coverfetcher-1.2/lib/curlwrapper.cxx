/*
 * curlwrapper.cxx: QObject wrapper around libcurl.
 * Author: Benjamin Johnson <obeythepenguin@users.sf.net>
 * Date: 2011/01/30
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
 */

#include "curlwrapper.h"

/*
 * CurlWrapper class constructor.
 */
CurlWrapper::CurlWrapper(QObject *parent, const char *name)
	: QObject(parent, name)
{
	// initialize CURL handles
	dl_multi = curl_multi_init();
	dl_handle = curl_easy_init();
	dl_headers = NULL;

	outputFile = NULL;	// until/unless we need it
	running_handles = 0;	// until we start downloading

	// this keeps the data moving
	timer = new QTimer(this);
	connect(timer, SIGNAL(timeout()), this, SLOT(downloadLoop()));
}

/*
 * CurlWrapper class destructor.
 */
CurlWrapper::~CurlWrapper()
{
	if (dl_multi && dl_handle)
		curl_multi_remove_handle(dl_multi, dl_handle);

	if (dl_handle)		curl_easy_cleanup(dl_handle);
	if (dl_multi)		curl_multi_cleanup(dl_multi);
	if (dl_headers)		curl_slist_free_all(dl_headers);

	if (outputFile) {
		if (outputFile->handle() != -1)
			outputFile->close();	// close if it's still open
		delete outputFile;
	}

	timer->stop();
	delete timer;
}

/*
 * Download data to memory.
 */
void CurlWrapper::getData(const QString &url)
{
	if (isRunning()) return;

	downloadToMemory = true;
	return startDownload(url);
}

/*
 * Download data to file on disk.
 */
void CurlWrapper::download(const QString &url, const QString &filename)
{
	if (isRunning()) return;

	outputFile = new QFile(filename);
	if (!outputFile->open(IO_WriteOnly | IO_Truncate)) {
		emit error("Failed to open \"" + filename + "\" for writing.");
		return;
	}

	downloadToMemory = false;
	return startDownload(url);
}

/*
 * Cancel a running download.
 */
void CurlWrapper::cancel()
{
	if (outputFile) {
		outputFile->close();
		delete outputFile;
		outputFile = NULL;
	}

	wasCanceled = true;
}

/*
 * Return URL of downloaded file.
 */
const QString CurlWrapper::url() const
{
	return pUrl;
}

/*
 * Return downloaded data.
 */
const QByteArray CurlWrapper::data() const
{
	return dlData;
}

/*
 * Return whether we're running or not.
 */
bool CurlWrapper::isRunning() const
{
	return running_handles > 0;
}

/*
 * Globally initialize libcurl.
 */
void CurlWrapper::init()
{
	curl_global_init(CURL_GLOBAL_ALL);
}

/*
 * Globally clean up libcurl.
 */
void CurlWrapper::cleanup()
{
	curl_global_cleanup();
}

/*
 * Set download handle options and start the download.
 */
void CurlWrapper::startDownload(const QString &url)
{
	pUrl = url;	// save for later reference
	wasCanceled = false;

	// empty our data buffer
	dlData.truncate(0);

	// some sites may not like automated downloaders
	dl_headers = curl_slist_append(dl_headers, "User-Agent: Dillo/2.2");

	// set basic handle options
	curl_easy_setopt(dl_handle, CURLOPT_URL, url.latin1());
	curl_easy_setopt(dl_handle, CURLOPT_HTTPHEADER, dl_headers);
	curl_easy_setopt(dl_handle, CURLOPT_ERRORBUFFER, dl_error);
	curl_easy_setopt(dl_handle, CURLOPT_HEADER, 0);
	curl_easy_setopt(dl_handle, CURLOPT_FOLLOWLOCATION, 1);

	// set up write data callback
	curl_easy_setopt(dl_handle, CURLOPT_WRITEDATA, (void*)this);
	curl_easy_setopt(dl_handle, CURLOPT_WRITEFUNCTION,
					CurlWrapper::writeCallback);

	// enable progress callback function
	curl_easy_setopt(dl_handle, CURLOPT_NOPROGRESS, 0L);
	curl_easy_setopt(dl_handle, CURLOPT_PROGRESSFUNCTION,
					CurlWrapper::progressCallback);
	curl_easy_setopt(dl_handle, CURLOPT_PROGRESSDATA, (void*)this);

	// start the download
	curl_multi_add_handle(dl_multi, dl_handle);
	CURLMcode retval = curl_multi_perform(dl_multi, &running_handles);
	if (retval != CURLM_OK) {
		emit error(dl_error);
		cancel();
	} else
		timer->start(10);
}

/*
 * Save data to local storage.
 * FIXME: This assumes ptr is a char* (size == 1).
 */
size_t CurlWrapper::storeData(void *ptr, size_t size, size_t nmemb)
{
	int offset = dlData.size();
	int dlSize = size * nmemb;
	dlData.resize(offset + dlSize);

	for (int i = 0; i < dlSize; i++)
		dlData[offset + i] = ((char*)ptr)[i];

	// If this isn't equal to dlSize, an error
	// occurred; let libcurl react appropriately:
	return dlData.size() - offset;
}

/*
 * Write data to output file.
 * FIXME: This assumes ptr is a char* (size == 1).
 */
size_t CurlWrapper::writeData(void *ptr, size_t size, size_t nmemb)
{
	Q_LONG retval = 0;
	for (int i = 0; i < nmemb; i++)
		retval += outputFile->writeBlock((char*)ptr + i, size);

	return (size_t)retval;
}

/*
 * Emit download progress signal.
 */
void CurlWrapper::setProgress(int done, int total)
{
	QString doneUnit = "bytes";
	QString totalUnit = "bytes";

	double dlnow = done, dltotal = total;
	if (dlnow / 1024.0 > 1) { dlnow /= 1024.0; doneUnit = "kB"; }
	if (dlnow / 1024.0 > 1) { dlnow /= 1024.0; doneUnit = "MB"; }
	if (dlnow / 1024.0 > 1) { dlnow /= 1024.0; doneUnit = "GB"; }

	if (dltotal / 1024.0 > 1) { dltotal /= 1024.0; totalUnit = "kB"; }
	if (dltotal / 1024.0 > 1) { dltotal /= 1024.0; totalUnit = "MB"; }
	if (dltotal / 1024.0 > 1) { dltotal /= 1024.0; totalUnit = "GB"; }

	QString doneText =
			QString::number(dlnow, 'f', 2) + " " + doneUnit;
	QString totalText =
			QString::number(dltotal, 'f', 2) + " " + totalUnit;

	emit progress(done, total);
	emit status("Downloaded " + doneText + " of " + totalText);
}

/*
 * Static write data callback.
 * Pass back to class instance.
 */
size_t CurlWrapper::writeCallback(void *ptr,
size_t size, size_t nmemb, void *userdata)
{
	CurlWrapper *cw = (CurlWrapper*)(userdata);
	if (cw->downloadToMemory)
		return cw->storeData(ptr, size, nmemb);
	else
		return cw->writeData(ptr, size, nmemb);
}

/*
 * Static progress callback.
 * Pass back to class instance.
 */
int CurlWrapper::progressCallback(void *clientp,
double dltotal, double dlnow, double ultotal, double ulnow)
{
	CurlWrapper *cw = (CurlWrapper*)(clientp);
	cw->setProgress(dlnow, dltotal);

	if (cw->wasCanceled)
		cw->timer->stop();

	// libcurl returns CURLE_ABORTED_BY_CALLBACK
	// if this function's return value != 0
	return cw->wasCanceled;
}

/*
 * Main download loop.
 * Keep the data moving.
 */
void CurlWrapper::downloadLoop()
{
	// running_handles == 0 indicates download complete
	if (!running_handles) {
		if (outputFile) {
			outputFile->close();
			outputFile = NULL;
			delete outputFile;
		}

		emit finished();
		return;
	}

	CURLMcode retval = curl_multi_perform(dl_multi, &running_handles);
	if (retval != CURLM_OK) {
		emit error(dl_error);
		cancel();
	}
}

#include "curlwrapper.moc"
