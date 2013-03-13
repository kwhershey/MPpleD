#ifndef FETCHER_H_
#define FETCHER_H_

#include <qdialog.h>
#include <qlayout.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qcombobox.h>
#include <qpushbutton.h>
#include <qstring.h>
#include <qpopupmenu.h>
#include <qdir.h>
#include <qimage.h>
#include <qaction.h>
#include <qprogressdialog.h>
#include <qerrormessage.h>

#include <curlwrapper.h>

#include "preview.h"

class CoverFetcher : public QDialog
{
	Q_OBJECT

	public:
		CoverFetcher(QWidget *parent = 0, const char *name = 0,
			bool modal = false, WFlags f = 0);
		~CoverFetcher();

	private:
		QBoxLayout *mainLayout;
		CoverPreview *preview;
		QPopupMenu *previewMenu;
		QLabel *logo;

		QGridLayout *layout;
		QLabel *labelArtist;
		QLineEdit *artist;
		QLabel *labelAlbum;
		QLineEdit *album;
		QLabel *labelSize;
		QComboBox *size;

		QBoxLayout *buttonLayout;
		QPushButton *buttonOK;
		QPushButton *buttonCancel;

		QAction *actionQuit;

		bool haveAlbumInfo;
		bool haveCover;

		CurlWrapper *getter;
		QProgressDialog *progress;
		QErrorMessage *errorMessage;

		QImage lastCover;
		QString lastCoverFilename;

	private slots:
		void accept();

		void gotAlbumInfo();
		void gotCover();
		void fetchError(const QString &message);

		void createGetter();
		void killGetter();
		void createProgress();

		void copyCover();
		void showSaveDialog();
};

#endif  // FETCHER_H_
