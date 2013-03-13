/*
 * fetcher.cxx: CoverFetcher class implementation.
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

#include <qapplication.h>
#include <qclipboard.h>
#include <qdom.h>
#include <qregexp.h>
#include <qurl.h>
#include <qmessagebox.h>
#include <qfiledialog.h>
#include <qwhatsthis.h>

#include "fetcher.h"

#include "../icons/stamps_16x16.xpm"
#include "../icons/lastfm_red.xpm"
#include "../icons/lastfm_black.xpm"

/*
 * CoverFetcher class constructor.
 */
CoverFetcher::CoverFetcher(QWidget *parent, const char *name,
bool modal, WFlags f)
	: QDialog(parent, name, modal, f)
{
	setCaption("Cover Fetcher");
	setIcon(QPixmap(stamps_16x16_xpm));

	mainLayout = new QVBoxLayout(this);
	mainLayout->setMargin(4);
	mainLayout->setSpacing(2);

	preview = new CoverPreview(this);
	preview->setText("The album cover will be displayed here.\n"
					"After downloading, right-click "
					"to copy or save.");
	QWhatsThis::add(preview, "Displays the most recently downloaded "
					"cover.  Right-click to copy the "
					"displayed cover to the clipboard, "
					"or to save it to disk.");
	preview->setDragEnabled(true);
	mainLayout->addWidget(preview);
	mainLayout->addSpacing(4);

	previewMenu = new QPopupMenu(this);
	previewMenu->insertItem("&Copy",
				this, SLOT(copyCover()), CTRL+Key_Y);
	previewMenu->insertItem("&Save",
				this, SLOT(showSaveDialog()), CTRL+Key_S);
	preview->setContextMenu(previewMenu);

	logo = new QLabel(this);
	logo->setAlignment(AlignCenter);
	logo->setPixmap(QPixmap(lastfm_black_xpm));
	QWhatsThis::add(logo, "Displays your last.fm connection status.  "
					"This will light red when you are "
					"successfully connected to last.fm.");

	layout = new QGridLayout(mainLayout);
	layout->setSpacing(2);
	int layoutRow = 0;

	labelArtist = new QLabel(this);
	labelArtist->setText("&Artist:");
	layout->addWidget(labelArtist, layoutRow, 0);

	artist = new QLineEdit(this);
	labelArtist->setBuddy(artist);
	QWhatsThis::add(artist, "Enter the name of an artist to search "
					"for.  You must also specify an "
					"album title.");
	layout->addWidget(artist, layoutRow, 1);
	layoutRow++;

	labelAlbum = new QLabel(this);
	labelAlbum->setText("A&lbum:");
	layout->addWidget(labelAlbum, layoutRow, 0);

	album = new QLineEdit(this);
	labelAlbum->setBuddy(album);
	QWhatsThis::add(album, "Enter the title of an album to search "
					"for.  In most cases you must also "
					"specify an artist.");
	layout->addWidget(album, layoutRow, 1);
	layoutRow++;

	labelSize = new QLabel(this);
	labelSize->setText("&Size:");
	layout->addWidget(labelSize, layoutRow, 0);

	size = new QComboBox(this);
	size->setEditable(false);
	size->insertItem("small");
	size->insertItem("medium");
	size->insertItem("large");
	size->insertItem("extralarge");
	// size->insertItem("mega");		// very large -- no fixed size
	size->setCurrentText("extralarge");
	labelSize->setBuddy(size);
	QWhatsThis::add(size, "Select the size of the cover to fetch.");
	layout->addWidget(size, layoutRow, 1);
	layoutRow++;

	mainLayout->addSpacing(4);

	buttonLayout = new QHBoxLayout(mainLayout);
	buttonLayout->setSpacing(2);
	buttonLayout->addWidget(logo);
	buttonLayout->addStretch(0);

	buttonOK = new QPushButton(this);
	buttonOK->setText("Download");
	buttonOK->setDefault(true);
	connect(buttonOK, SIGNAL(clicked()), this, SLOT(accept()));
	buttonLayout->addWidget(buttonOK);

	buttonCancel = new QPushButton(this);
	buttonCancel->setText("Close");
	connect(buttonCancel, SIGNAL(clicked()), this, SLOT(reject()));
	buttonLayout->addWidget(buttonCancel);

	actionQuit = new QAction(this);
	actionQuit->setAccel(CTRL+Key_Q);
	connect(actionQuit, SIGNAL(activated()), this, SLOT(reject()));

	getter = NULL;		// create on demand as needed
	progress = NULL;	// create on demand as needed
	errorMessage = NULL;	// create on demand if needed

	CurlWrapper dummy;	// Test our connection to last.fm.
	connect(&dummy, SIGNAL(error(const QString&)),
				this, SLOT(fetchError(const QString&)));

	dummy.getData("http://ws.audioscrobbler.com/");
	while (dummy.isRunning())
		qApp->processEvents();

	// Non-empty data indicates the connection succeeded.
	// Note: fetchError(const QString&) will automatically
	// be called if an error occurred -- see just above.
	if (!dummy.data().isEmpty())
		logo->setPixmap(QPixmap(lastfm_red_xpm));

	setFixedWidth(minimumWidth());
	artist->setFocus();
}

/*
 * CoverFetcher class destructor.
 */
CoverFetcher::~CoverFetcher()
{
	if (getter)
		delete getter;
	if (progress)
		delete progress;
	if (errorMessage)
		delete errorMessage;

	delete actionQuit;

	delete buttonCancel;
	delete buttonOK;
	delete buttonLayout;

	delete size;
	delete labelSize;
	delete album;
	delete labelAlbum;
	delete artist;
	delete labelArtist;
	delete layout;

	delete logo;
	delete previewMenu;
	delete preview;
	delete mainLayout;
}

/*
 * Fetch the album information from last.fm.
 * Called when the user clicks the Download button.
 */
void CoverFetcher::accept()
{
	haveAlbumInfo = false;
	haveCover = false;

	QString url = "http://ws.audioscrobbler.com/2.0/";
	url.append("?method=album.getinfo");
	url.append("&api_key=f3a26c7c8b4c4306bc382557d5c04ad5");

	if (album->text().isEmpty())
		return fetchError("You must enter an album name.");

	// Note: QUrl::encode(const QString&)
	// does NOT return the encoded string
	QString q_artist = artist->text();
	QUrl::encode(q_artist);
	QString q_album = album->text();
	QUrl::encode(q_album);

	if (!q_artist.isEmpty())
		url.append("&artist=" + q_artist);
	if (!q_album.isEmpty())
		url.append("&album=" + q_album);

	createGetter();
	connect(getter, SIGNAL(finished()), this, SLOT(gotAlbumInfo()));
	getter->getData(url);		// fetch album information
}

/*
 * Called when getter returns album information.
 * Parse the album information and find the cover URL.
 */
void CoverFetcher::gotAlbumInfo()
{
	if (haveAlbumInfo)
		return;
	haveAlbumInfo = true;

	QString coverUrl;
	QString xmlData = getter->data();

	killGetter();		// XXX No using getter beyond this line! XXX

	QDomDocument doc;
	if (!doc.setContent(xmlData))
		return fetchError("The XML obtained from last.fm "
							"is invalid.");

	// Let's just admit that Qt's XML parsing is heinously ugly.
	// What we're looking for is something like
	// 	<album><image size="extralarge"> ... </image></album>
	const QDomNodeList list =
			doc.documentElement().namedItem("album").childNodes();
	for (int i = 0; i < list.count(); i++) {
		QDomNode n = list.item(i);
		if (n.nodeName() != "image") continue;
		if (!n.hasAttributes()) continue;

		QString imageSize =
				n.attributes().namedItem("size").nodeValue();
		if (imageSize == size->currentText())
			if (n.isElement()) {
				coverUrl = n.toElement().text();
				break;
			}
	}

	// No cover URL?  This could be a problem.
	// Better let the user know what's going on.
	if (coverUrl.isEmpty())
		return fetchError("Could not find " +
					size->currentText() + " cover "
					"for \"" + album->text() + "\".");

	createGetter();
	connect(getter, SIGNAL(finished()), this, SLOT(gotCover()));
	getter->getData(coverUrl);	// fetch cover artwork
}

/*
 * Called when getter retrieves album artwork.
 */
void CoverFetcher::gotCover()
{
	if (haveCover)
		return;
	haveCover = true;

	lastCover = QImage(getter->data());

	// Save last cover filename.
	lastCoverFilename = album->text();
	if (!artist->text().isEmpty())
		lastCoverFilename.prepend(artist->text() + " - ");

	// Show preview in preview panel.
	preview->setCoverData(lastCover);
	preview->setCoverName(lastCoverFilename);

	artist->clear();
	album->clear();
	artist->setFocus();
}

/*
 * Called if getter aborts with an error.
 */
void CoverFetcher::fetchError(const QString &message)
{
	if (progress && progress->isVisible())
		progress->close();

	if (!errorMessage)
		errorMessage = new QErrorMessage(this);

	if (sender())
		errorMessage->setCaption("Error in " +
					QString(sender()->className()));
	else
		errorMessage->setCaption("Error");

	errorMessage->message(message);
}

/*
 * Create a new getter and connect signals appropriately.
 */
void CoverFetcher::createGetter()
{
	if (getter)
		killGetter();
	if (!progress)
		createProgress();

	getter = new CurlWrapper(this);
	connect(getter, SIGNAL(progress(int, int)),
				progress, SLOT(setProgress(int, int)));
	connect(getter, SIGNAL(error(const QString&)),
				this, SLOT(fetchError(const QString&)));
}

/*
 * Destroy getter and set the pointer safely to NULL.
 */
void CoverFetcher::killGetter()
{
	if (!getter)
		return;

	delete getter;
	getter = NULL;
}

/*
 * Create the progress dialog.
 */
void CoverFetcher::createProgress()
{
	progress = new QProgressDialog(this);
	progress->setAutoReset(true);
	progress->setAutoClose(true);
	progress->setMinimumDuration(3000);	// 3 seconds
	progress->setLabelText("Downloading data...");
}

/*
 * Copy the currently displayed cover to the clipboard.
 */
void CoverFetcher::copyCover()
{
	if (lastCover.isNull()) return;

	QApplication::clipboard()->setImage(lastCover, QClipboard::Clipboard);
}

/*
 * Show a dialog allowing the user to save the cover to disk.
 */
void CoverFetcher::showSaveDialog()
{
	if (lastCover.isNull()) return;

	QDir desktop = QDir::home();
	desktop.cd("Desktop");

	const QString FILTER_BMP = "Bitmap Images (*.bmp)";
	const QString FILTER_JPEG = "JPEG Images (*.jpg)";
	const QString FILTER_PNG = "PNG Images (*.png)";

	QFileDialog dialog(this);
	dialog.setDir(desktop);
	dialog.setMode(QFileDialog::AnyFile);
	dialog.setCaption("Save Cover");
	dialog.addFilter(FILTER_BMP);
	dialog.addFilter(FILTER_JPEG);
	dialog.addFilter(FILTER_PNG);
	dialog.setSelectedFilter(FILTER_JPEG);
	dialog.setSelection(lastCoverFilename);

	CoverPreview preview(this, lastCover);
	dialog.setContentsPreviewEnabled(true);
	dialog.setContentsPreview(&preview, &preview);
	dialog.setPreviewMode(QFileDialog::Contents);

	// If the user rejected the dialog, return.
	if (dialog.exec() != QDialog::Accepted) return;

	// Determine output format based on extension.
	QString outputFormat;
	QString filename = dialog.selectedFile();
	if (dialog.selectedFilter() == FILTER_BMP) {
		outputFormat = "BMP";
		filename.append(".bmp");
	} else if (dialog.selectedFilter() == FILTER_JPEG) {
		outputFormat = "JPEG";
		filename.append(".jpg");
	} else if (dialog.selectedFilter() == FILTER_PNG) {
		outputFormat = "PNG";
		filename.append(".png");
	}

	// Save the file to disk with the highest possible image quality.
	lastCover.save(filename, outputFormat.latin1(), 100);
}

#include "fetcher.moc"
