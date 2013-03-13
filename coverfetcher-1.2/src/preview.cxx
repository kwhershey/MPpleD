/*
 * preview.cxx: Cover artwork preview widget.
 * Author: Benjamin Johnson <obeythepenguin@users.sf.net>
 * Date: 2011/05/20
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

#include <qbuffer.h>
#include <qcstring.h>
#include <qpixmap.h>
#include <qdragobject.h>

#include <cstdlib>
using std::getenv;

#include "preview.h"

/*
 * CoverPreview class constructor.
 */
CoverPreview::CoverPreview(QWidget *parent, const char *name)
	: QLabel(parent, name)
{
	init();
}

/*
 * CoverPreview class constructor.
 */
CoverPreview::CoverPreview(QWidget *parent, const QImage &data)
	: QLabel(parent)
{
	init();
	setCoverData(data);
}

/*
 * CoverPreview class destructor.
 */
CoverPreview::~CoverPreview()
{
	if (!tempFilename.isEmpty())
		clearLastCover();
}

/*
 * Dummy function for QFilePreview.
 * Ignore the selected file and always show the cover artwork.
 */
void CoverPreview::previewUrl(const QUrl &u)
{
}

/*
 * Fill the internal cover data buffer
 * and display its contents as a QPixmap.
 */
void CoverPreview::setCoverData(const QImage &data)
{
	coverData = data;
	setPixmap(QPixmap(coverData));

	if (!tempFilename.isEmpty())
		clearLastCover();
}

/*
 * Set the internal cover name.
 */
void CoverPreview::setCoverName(const QString &name)
{
	coverName = name;
}

/*
 * Set whether dragging cover data from widget is enabled.
 */
void CoverPreview::setDragEnabled(bool enabled)
{
	dragEnabled = enabled;
}

/*
 * Set context menu.
 */
void CoverPreview::setContextMenu(QPopupMenu *menu)
{
	contextMenu = menu;
}

/*
 * Common functions shared by all constructors.
 */
void CoverPreview::init()
{
	setFixedSize(300, 300);
	setAlignment(AlignCenter);
	setFrameShape(QFrame::StyledPanel);
	setFrameShadow(QFrame::Sunken);

	dragEnabled = false;
	contextMenu = NULL;
}

/*
 * Start dragging cover data from widget, if enabled.
 * The image is converted to BMP format using a temporary buffer
 * to provide better compatibility with Microsoft Windows applications.
 */
void CoverPreview::startImageDrag()
{
	QByteArray tempImageData;
	QBuffer buffer(tempImageData);

	buffer.open(IO_WriteOnly);
	coverData.save(&buffer, "BMP", 100);
	buffer.close();

	QImage tempImage(tempImageData);
	QDragObject *d = new QImageDrag(tempImage, this);
	d->dragCopy();
}

/*
 * Start dragging cover data from widget, if enabled.
 * The dragged content is the absolute filename of a temporary file
 * in BMP format.  This is more widely supported in applications than
 * dragging the image content directly.  The temporary file is deleted
 * automatically on the next fetch, or when Cover Fetcher is exited.
 */
void CoverPreview::startImageUriDrag()
{
	if (tempFilename.isEmpty())
		saveLastCover();

	QStrList names;
	names.append(tempFilename.latin1());

	QDragObject *d = new QUriDrag(names, this);
	d->drag();
}

/*
 * Overloaded mouse move event.
 * Call CoverPreview::startImageDrag() if it's enabled.
 */
void CoverPreview::mouseMoveEvent(QMouseEvent *e)
{
	if (dragEnabled && e->state() & LeftButton
					&& !coverData.isNull())
		startImageUriDrag();
	else
		return QLabel::mouseMoveEvent(e);
}

/*
 * Display context menu, if enabled.
 */
void CoverPreview::contextMenuEvent(QContextMenuEvent *e)
{
	if (contextMenu && !coverData.isNull()) {
		e->accept();
		contextMenu->exec(e->globalPos());
	} else
		return QLabel::contextMenuEvent(e);
}

/*
 * Save the last downloaded cover to a temporary file in BMP format.
 * This provides the best compatibility with Microsoft Windows applications.
 */
void CoverPreview::saveLastCover()
{
	static QString tempDir = getenv("TEMP");
	if (tempDir.isEmpty())	tempDir = getenv("TMP");
	if (tempDir.isEmpty())	tempDir = getenv("TMPDIR");

	if (coverName.isEmpty())
		coverName = "(untitled)";
	tempFilename = tempDir + "/" + coverName + ".bmp";

	coverData.save(tempFilename, "BMP", 100);
}

/*
 * Delete temporary files left over from the last downloaded cover.
 */
void CoverPreview::clearLastCover()
{
	if (QFile::exists(tempFilename))
		QFile::remove(tempFilename);

	tempFilename = QString::null;
}
